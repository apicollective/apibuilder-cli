module ApibuilderCli
  module Commands
    class ProjectWithGenerator
      attr_reader :project, :generator, :target, :changes
      def initialize(project, generator, target)
        @project = project
        @generator = generator
        @target = target
        @changes = []
      end
      def add(change)
        @changes << change
      end
    end

    class Update
      def initialize(client, app_config, args)
        @client = client
        @app_config = app_config
        @org = args[:org]
        @app = args[:app]
      end

      def run
        puts "Fetching code from #{@client.url}"
        tracked_files = ApibuilderCli::FileTracker.new(@app_config.project_dir, { :updating_only => { :org => @org, :app => @app } })

        all = @app_config.projects(:org => @org, :app => @app).map do |project|
          project.generators.map { |generator|
            puts "  #{project.org}/#{project.name}/#{project.version}/#{generator.name}..."
            generator.targets.map { |target|
              ProjectWithGenerator.new(project, generator.dup, target.dup)
            }
          }
        end.flatten

        all.each_slice(MAX_THREADS) do |pairs|
          threads = pairs.map do |pair|
            Thread.new do
              project = pair.project
              generator = pair.generator
              target = pair.target

              base_target_path = File.join(@app_config.project_dir, target)
              reference_target_path = File.join(@app_config.project_dir, ApibuilderCli::Config::APIBUILDER_LOCAL_DIR, target)

              begin
                attributes = generator.attributes.map { |k, v| Io::Apibuilder::Generator::V0::Models::Attribute.new(:name => k, :value => v) }
                form = Io::Apibuilder::Api::V0::Models::CodeForm.new(:attributes => attributes)
                code = ApibuilderCli::Util.call(@client) do
                  @client.code.post_by_generator_key(project.org, project.name, project.version, generator.name, form).files
                end
                if generator.files.nil?
                  files = code
                else
                  files = filter_files(generator.files, code, generator.name)
                end
                files.each do |f|
                  # For scaffolding (i.e. locally-editable) files, store a copy of the original in the .apibuilder directory in order to
                  # demonstrate diffs to be manually ported to the scaffolding files.
                  [[f, base_target_path], file_is_scaffolding?(f) ? [Io::Apibuilder::Generator::V0::Models::File.new(f.to_hash.merge(:flags => nil)), reference_target_path] : nil].compact.each do |file, file_target_path|
                    final_target_path = @app_config.settings.code_create_directories && file.dir ? File.join(file_target_path, file.dir) : file_target_path

                    # check if target path ends with the filename - if not, this is a directory target and need to check if dir exists
                    # for example: "play_2_x_routes: api/conf/routes" is a file
                    # while "anorm_2_x_parsers: api/app/generated" should be a directory we check if exists
                    FileUtils.mkdir_p(final_target_path) unless final_target_path.include?(file.name) || Dir.exist?(final_target_path) || File.exist?(final_target_path)

                    target_path = (File.directory?(final_target_path) ? File.join(final_target_path, file.name) : final_target_path).dup
                    existing_source = File.exist?(target_path) ? IO.read(target_path).strip : ""

                    print "    " + target_path.sub(/^#{@app_config.project_dir}\/?/, '') + ": "
                    tracked_files.track!(project.org, project.name, generator.name, target_path)
                    if file_is_scaffolding?(file)
                      if existing_source == ""
                        pair.add :source => file.contents, :generator => generator.name, :target => target_path
                      end
                    else
                      if different?(file.contents, existing_source)
                        pair.add :source => file.contents, :generator => generator.name, :target => target_path
                      end
                    end
                  end
                end
              rescue Exception => e
                handle_server_error(e)
              end
            end
          end
          threads.each(&:join)
        end

        puts ""
        updates = all.map { |g| g.changes }.flatten
        if updates.empty?
          puts "No changes"
        else
          puts "Copying updated code"
          updates.each do |data|
            puts " - #{data[:generator]} => #{data[:target]}"
            ApibuilderCli::Util.write_to_file(data[:target], data[:source])
          end
          if @app_config.settings.code_cleanup_generated_files
            puts "Cleaning up obsolete code"
            tracked_files.to_cleanup.each do |file|
              file_dir = File.join(File.split(file).shift)
              cmd = "rm #{file}; rmdir -p #{file_dir} > /dev/null 2>&1"
              puts "** #{cmd}"
              `#{cmd}`
            end
          end
        end

        tracked_files.save!
      end

    end
  end
end
