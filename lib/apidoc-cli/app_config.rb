# Reads the apidoc application configuration file (.apidoc filename by convention)
module ApidocCli

  class AppConfig

    DEFAULT_FILENAME = ".apidoc" unless defined?(DEFAULT_FILENAME)

    attr_reader :code

    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || DEFAULT_FILEPATH, String)
      Preconditions.check_state(File.exists?(@path), "Apidoc application config file[#{@path}] not found")

      yaml = YAML.load(IO.read(@path))
      code_projects = (yaml["code"] || {}).map do |org_key, project_map|
        project_map.map do |project_name, data|
          generators = data.map do |name, target|
            Generator.new(name, target)
          end
          project = Project.new(org_key, project_name, generators)
        end
      end.flatten

      @code = Code.new(code_projects)
    end

    class Code

      attr_reader :projects

      def initialize(projects)
        @projects = Preconditions.assert_class(projects, Array)
        Preconditions.assert_class_or_nil(projects.first, Project)
      end

    end

    class Project

      attr_reader :org, :name, :generators

      def initialize(org, name, generators)
        @org = Preconditions.assert_class(org, String)
        @name = Preconditions.assert_class(name, String)
        @generators = Preconditions.assert_class(generators, Array)
        Preconditions.check_state(!generators.empty?, "Must have at least one generator")
        Preconditions.assert_class(generators.first, Generator)
      end

    end

    class Generator

      attr_reader :name, :target

      def initialize(name, target)
        @name = Preconditions.assert_class(name, String)
        @target = Preconditions.assert_class(target, String)
      end

    end

  end

end
