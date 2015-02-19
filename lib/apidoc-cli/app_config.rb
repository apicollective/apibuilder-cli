# Reads the apidoc application configuration file (.apidoc filename by convention)
module ApidocCli

  class AppConfig

    DEFAULT_FILENAME = ".apidoc" unless defined?(DEFAULT_FILENAME)

    attr_reader :projects

    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || DEFAULT_FILEPATH, String)
      Preconditions.check_state(File.exists?(@path), "Apidoc application config file[#{@path}] not found")

      yaml = YAML.load(IO.read(@path))
      @projects = yaml.map do |project_name, data|
        Project.new(project_name, data)
      end
    end

  end

  class Project

    attr_reader :name

    def initialize(name, data)
      @name = Preconditions.assert_class(name, String)
      @data = Preconditions.assert_class(data, Hash)
    end

    # Yields the name of the generator and the path relative to the
    # location of the .apidoc file.
    def each_generator
      @data.each do |generator, target|
        yield generator, target
      end
    end

  end

end
