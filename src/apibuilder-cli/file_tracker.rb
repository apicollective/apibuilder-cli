module ApibuilderCli

  class FileTracker

    def FileTracker.default_path(project_dir)
      Util.file_join(project_dir, ApibuilderCli::Config::APIBUILDER_LOCAL_DIR, ".tracked_files")
    end

    # Options:
    #   :path => Mostly here for injecting test config
    #   :updating_only => Filter to indicate which orgs/apps are being updated. All other orgs/apps
    #     will be carried forward untouched. Options:
    #       :org => The organization that contains the project
    #       :app => The project name that is getting updated
    def initialize(project_dir, opts={})
      @project_dir = Preconditions.check_not_blank(project_dir, "ERROR: Missing project_dir")
      @path = Preconditions.assert_class(opts.delete(:path) || FileTracker.default_path(@project_dir), String)
      @updating_only = opts.delete(:updating_only) || nil
      @previous = {}
      @current = {}
      @current_raw = []
      if File.exists?(@path)
        contents = IO.read(@path).strip
        if contents != ""
          @previous = begin
                        YAML.load(contents)
                      rescue Psych::SyntaxError => e
                        puts "ERROR parsing YAML file at #{@path}:\n  #{e}"
                        exit(1)
                      end
        end
      end
      unless @updating_only.nil? || (@updating_only[:org].nil? && @updating_only[:app].nil?)
        @previous.each do |org_name, projects|
          projects.each do |project_name, generators|
            if ((!@updating_only[:org].nil? && org_name != @updating_only[:org]) || (!@updating_only[:app].nil? && project_name != @updating_only[:app]))
              generators.each do |generator_name, files|
                files.each do |file|
                  track!(org_name, project_name, generator_name, file)
                end
              end
            end
          end
        end
      end
    end

    # Saves the tracked file list to the file
    def save!
      output = {}
      if @current_raw.size > 0
        # Using .keys here to preserve deterministic ordering
        @current.keys.sort.each do |org_name|
          @current[org_name].keys.sort.each do |project_name|
            @current[org_name][project_name].keys.sort.each do |generator_name|
              output[org_name] = {} if output[org_name].nil?
              output[org_name][project_name] = {} if output[org_name][project_name].nil?
              output[org_name][project_name][generator_name] = {} if output[org_name][project_name][generator_name].nil?
              output[org_name][project_name][generator_name] = @current[org_name][project_name][generator_name].uniq.sort
            end
          end
        end
      end
      ApibuilderCli::Util.write_to_file(@path, output.to_yaml)
    end

    # Lists files that were tracked, but no longer are - should be deleted
    def to_cleanup
      @previous.map { |org_name, projects|
        projects.map { |project_name, generators|
          generators.map { |generator_name, files|
            files - @current_raw
          }
        }
      }.flatten.sort.map{|f| Util.file_join(@project_dir, f)}
    end

    # Keep track of the given file
    def track!(org, project, generator, file)
      Preconditions.assert_class(org, String)
      Preconditions.assert_class(project, String)
      Preconditions.assert_class(generator, String)
      Preconditions.assert_class(file, String)
      file = file.sub(/^#{@project_dir}\/?/, '')

      @current[org] = {} if @current[org].nil?
      @current[org][project] = {} if @current[org][project].nil?
      @current[org][project][generator] = [] if @current[org][project][generator].nil?
      @current[org][project][generator] << file
      @current_raw << file

      @previous[org][project][generator].select!{ |previous_file| previous_file != file } if @previous[org] && @previous[org][project] && @previous[org][project][generator]
    end

  end
end