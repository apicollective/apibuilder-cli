# Reads the apibuilder application configuration file (.apibuilder/config filename by convention)
module ApibuilderCli

  class AppConfig

    DEFAULT_FILENAMES = ["#{ApibuilderCli::Config::APIBUILDER_LOCAL_DIR}/config", ".apibuilder", ".apidoc"] unless defined?(DEFAULT_FILENAMES)

    attr_reader :settings, :code, :project_dir

    def AppConfig.default_path
      path = find_config_file
      path_root = Dir.pwd
      if path.nil?
        git_root = `git rev-parse --show-toplevel 2> /dev/null`.strip
        if git_root != ""
          path = find_config_file(git_root)
          path_root = git_root unless path.nil?
        end
      end
      if path.nil?
        puts "**ERROR** Could not find apibuilder configuration file. Expected file to be located in current directory or the project root directory and named: %s" % DEFAULT_FILENAMES.first
        exit(1)
      end
      if path != DEFAULT_FILENAMES.first
        puts "******************** WARNING ********************"
        puts "** File %s is now deprecated and should be named %s. Moving it..." % [path, DEFAULT_FILENAMES.first]
        ["git mv #{path} .apibuilder.tmp", "mkdir #{ApibuilderCli::Config::APIBUILDER_LOCAL_DIR}", "git mv .apibuilder.tmp #{DEFAULT_FILENAMES.first}"].each do |cmd|
          puts "** #{cmd}"
          `#{cmd}`
        end
        puts "*************************************************"
        path = DEFAULT_FILENAMES.first
      end
      Util.file_join(path_root, path)
    end

    def AppConfig.find_config_file(root_dir = nil)
      DEFAULT_FILENAMES.find { |p| File.exists?(Util.file_join(root_dir, p)) }
    end
      
    def AppConfig.parse_project_dir(path)
      project_dir = File.dirname(path)
      # If the config file is buried in a directory starting with '.', bubble up to the
      # directory that contains that '.' directory.
      nested_dirs = project_dir
                      .split("/")
                      .reverse
                      .drop_while{ |dir| !dir.start_with?(".") }
      nested_dirs = nested_dirs.drop(1) if nested_dirs.length > 0 && nested_dirs[0].start_with?(".")
      project_dir = nested_dirs.reverse.join("/") if nested_dirs.length > 0
      project_dir
    end

    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || AppConfig.default_path, String)
      Preconditions.check_state(File.exists?(@path), "Apibuilder application config file[#{@path}] not found")

      contents = IO.read(@path)
      yaml = begin
               YAML.load(contents)
             rescue Psych::SyntaxError => e
               puts "ERROR parsing YAML file at #{@path}:\n  #{e}"
               exit(1)
             end

      @settings = Settings.new(yaml['settings'] || {})

      code_projects = (yaml["code"] || {}).map do |org_key, project_map|
        project_map.map do |project_name, data|
          version = data['version'].to_s.strip
          if version == ""
            raise "File[#{@path}] Missing version for org[#{org_key}] project[#{project_name}]"
          end
          if data['generators'].is_a?(Hash)
            generators = data['generators'].map do |name, data|
              Generator.new(name, data)
            end
          elsif data['generators'].is_a?(Array)
            generators = data['generators'].map do |generator|
              Generator.new(generator['generator'], generator)
            end
          else
            raise "File[#{@path}] Missing generators for org[#{org_key}] project[#{project_name}]"
          end
          project = Project.new(org_key, project_name, version, generators)
        end
      end.flatten

      @code = Code.new(code_projects)

      @project_dir = AppConfig.parse_project_dir(@path)
    end

    class Code

      attr_reader :projects

      def initialize(projects)
        @projects = Preconditions.assert_class(projects, Array)
        Preconditions.assert_class_or_nil(projects.first, Project)
      end

    end

    class Settings

      attr_reader :code_create_directories, :code_cleanup_generated_files

      def initialize(data)
        @code_create_directories = data.has_key?("code.create.directories") ? data.delete("code.create.directories") : false
        @code_cleanup_generated_files = data.has_key?("code.cleanup.generated.files") ? data.delete("code.cleanup.generated.files") : false
        Preconditions.check_state(data.empty?, "Invalid settings: #{data.keys.sort}")
      end

    end
    
    class Project

      attr_reader :org, :name, :version, :generators

      def initialize(org, name, version, generators)
        @org = Preconditions.assert_class(org, String)
        @name = Preconditions.assert_class(name, String)
        @version = Preconditions.assert_class(version, String)
        @generators = Preconditions.assert_class(generators, Array)
        Preconditions.check_state(!generators.empty?, "Must have at least one generator")
        Preconditions.assert_class(generators.first, Generator)
      end

    end

    class Generator

      attr_reader :name, :targets, :files

      # @param target The name of a file path or a
      # directory. Preferred usage is a directory, but paths are
      # supported based on the initial version of the configuration
      # files.
      def initialize(name, data)
        @name = Preconditions.assert_class(name, String)
        if data.is_a?(Array)
          Preconditions.assert_class(data.first, String)
          @targets = data
          @files = nil
        elsif data.is_a?(String)
          Preconditions.assert_class(data, String)
          @targets = [data]
          @files = nil
        elsif data['files'].nil?
          Preconditions.assert_class(data['target'], String)
          @targets = [data['target']]
          @files = nil
        elsif data['files'].is_a?(Array)
          Preconditions.assert_class(data['target'], String)
          Preconditions.assert_class(data['files'].first, String)
          @targets = [data['target']]
          @files = data['files']
        else
          Preconditions.assert_class(data['target'], String)
          Preconditions.assert_class(data['files'], String)
          @targets = [data['target']]
          @files = [data['files']]
        end
      end
    end

  end

end
