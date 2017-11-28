module ApibuilderCli

  class FileTracker

    def FileTracker.default_path
      "#{ApibuilderCli::Config::APIBUILDER_LOCAL_DIR}/.tracked_files"
    end

    # Options:
    #   :path => Mostly here for injecting test config
    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || FileTracker.default_path, String)
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
    end

    # Saves the tracked file list to the file
    def save!
      if @current_raw.size > 0
        @current.each do |org_name, projects|
          projects.each do |project_name, generators|
            generators.each do |generator_name, files|
              files.uniq!
              files.sort!
            end
          end
        end
      end
      ApibuilderCli::Util.write_to_file(@path, @current.to_yaml)
    end

    # Lists files that were tracked, but no longer are - should be deleted
    def to_cleanup
      @previous.map { |org_name, projects|
        projects.map { |project_name, generators|
          generators.map { |generator_name, files|
            files - @current_raw
          }
        }
      }.flatten.sort
    end

    # Keep track of the given file
    def track!(org, project, generator, file)
      Preconditions.assert_class(org, String)
      Preconditions.assert_class(project, String)
      Preconditions.assert_class(generator, String)
      Preconditions.assert_class(file, String)

      @current[org] = {} if @current[org].nil?
      @current[org][project] = {} if @current[org][project].nil?
      @current[org][project][generator] = [] if @current[org][project][generator].nil?
      @current[org][project][generator] << file
      @current_raw << file

      @previous[org][project][generator].select!{ |previous_file| previous_file != file } if @previous[org] && @previous[org][project] && @previous[org][project][generator]
    end

  end
end