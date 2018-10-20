load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::AppConfig do

  describe ApibuilderCli::AppConfig::Generator do

    it "constructor for a single file" do
      g = ApibuilderCli::AppConfig::Generator.new("ruby_client", "/tmp/client.rb")
      expect(g.name).to eq("ruby_client")
      expect(g.targets).to eq(["/tmp/client.rb"])
    end

    it "constructor for multiple files" do
      g = ApibuilderCli::AppConfig::Generator.new("ruby_client", ["/tmp/client.rb", "/tmp/bar"])
      expect(g.name).to eq("ruby_client")
      expect(g.targets).to eq(["/tmp/client.rb", "/tmp/bar"])
    end

  end

  describe ApibuilderCli::AppConfig::Project do

    it "constructor" do
      generators = [ApibuilderCli::AppConfig::Generator.new("ruby_client", "/tmp/client.rb")]

      project = ApibuilderCli::AppConfig::Project.new("apicollective", "apibuilder", "0.1.2", generators)
      expect(project.org).to eq("apicollective")
      expect(project.name).to eq("apibuilder")
      expect(project.version).to eq("0.1.2")
      expect(project.generators.map(&:name)).to eq(["ruby_client"])
    end

  end

  describe ApibuilderCli::AppConfig do

    before do
      @sample_file = ApibuilderCli::Util.write_to_temp_file("""
settings:
  code.create.directories: true
code:
  apicollective:
    apibuilder:
      version: latest
      generators:
        play_2_3_client: generated/app/ApibuilderClient.scala
        play_2_x_routes: api/conf/routes
    apibuilder-spec:
      version: latest
      generators:
        play_2_3_client: generated/app/ApibuilderSpec.scala
    apibuilder-generator:
      version: latest
      generators:
        play_2_3_client: generated/app/ApibuilderGenerator.scala
  happycorp:
    api-salary-calculator:
        version: 1.3.5
        generators:
          - generator: http4s_0_18
            target: src/main/generated
            files:
              - HappycorpApiSalaryCalculatorV0Client.scala
          - generator: http4s_0_18
            target: src/test/generated
            files:
              - HappycorpApiSalaryCalculatorV0MockClient.scala
  foo:
    bar:
      version: 0.0.1
      generators:
        ruby_client: /tmp/client.rb
      """.strip)
    end

    it "reads file" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      expect(app_config.code.projects.map(&:name).sort).to eq(["api-salary-calculator", "apibuilder", "apibuilder-generator", "apibuilder-spec", "bar"])

      expect(app_config.settings.code_create_directories).to eq(true)
      apibuilder = app_config.code.projects.find { |p| p.name == "apibuilder" }
      expect(apibuilder.org).to eq("apicollective")
      expect(apibuilder.name).to eq("apibuilder")
      expect(apibuilder.version).to eq("latest")
      expect(apibuilder.generators.map(&:name).sort).to eq(["play_2_3_client", "play_2_x_routes"])

      bar = app_config.code.projects.find { |p| p.name == "bar" }
      expect(bar.org).to eq("foo")
      expect(bar.name).to eq("bar")
      expect(bar.version).to eq("0.0.1")
      expect(bar.generators.map(&:name).sort).to eq(["ruby_client"])

      salary_calculator = app_config.code.projects.find { |p| p.name == "api-salary-calculator" }
      expect(salary_calculator.org).to eq("happycorp")
      expect(salary_calculator.name).to eq("api-salary-calculator")
      expect(salary_calculator.version).to eq("1.3.5")
      expect(salary_calculator.generators.size).to eq(2)
      salary_gen0 = salary_calculator.generators[0]
      salary_gen1 = salary_calculator.generators[1]
      expect(salary_gen0.name).to eq("http4s_0_18")
      expect(salary_gen0.targets).to eq(["src/main/generated"])
      expect(salary_gen0.files).to eq(["HappycorpApiSalaryCalculatorV0Client.scala"])
      expect(salary_gen1.name).to eq("http4s_0_18")
      expect(salary_gen1.targets).to eq(["src/test/generated"])
      expect(salary_gen1.files).to eq(["HappycorpApiSalaryCalculatorV0MockClient.scala"])

    end

    it "sets version and writes file" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      expect(app_config.settings.code_create_directories).to eq(true)

      apibuilder = app_config.code.projects.find { |p| p.name == "apibuilder" }
      expect(apibuilder.org).to eq("apicollective")
      expect(apibuilder.name).to eq("apibuilder")
      expect(apibuilder.version).to eq("latest")
      expect(apibuilder.generators.map(&:name).sort).to eq(["play_2_3_client", "play_2_x_routes"])

      bar = app_config.code.projects.find { |p| p.name == "bar" }
      expect(bar.org).to eq("foo")
      expect(bar.name).to eq("bar")
      expect(bar.version).to eq("0.0.1")
      expect(bar.generators.map(&:name).sort).to eq(["ruby_client"])

      app_config.set_version("foo", "bar", "0.0.2")
      app_config.save!

      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)

      apibuilder = app_config.code.projects.find { |p| p.name == "apibuilder" }
      expect(apibuilder.org).to eq("apicollective")
      expect(apibuilder.name).to eq("apibuilder")
      expect(apibuilder.version).to eq("latest")
      expect(apibuilder.generators.map(&:name).sort).to eq(["play_2_3_client", "play_2_x_routes"])

      bar = app_config.code.projects.find { |p| p.name == "bar" }
      expect(bar.org).to eq("foo")
      expect(bar.name).to eq("bar")
      expect(bar.version).to eq("0.0.2")
      expect(bar.generators.map(&:name).sort).to eq(["ruby_client"])
    end

    it "sets the project_dir" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      expect(app_config.project_dir).to eq(File.dirname(@sample_file))
    end
  end

  describe "ApibuilderCli::AppConfig.default_path" do
    it "should correctly find the project root when in the root dir" do
      in_tmpdir do |dir|
        Dir.mkdir(File.join(dir, ".apibuilder"))
        ApibuilderCli::Util.write_to_file("#{dir}/.apibuilder/config", """
code:
  apicollective:
    apibuilder:
      version: latest
      generators:
        play_2_3_client: generated/app/ApibuilderClient.scala
      """.strip)
        app_config = ApibuilderCli::AppConfig.new
        expect(app_config.project_dir).to eq(dir)
      end
    end

    it "should correctly find the project root when in the root directory the git has been initialized" do
      in_tmpdir do |dir|
        Dir.mkdir(File.join(dir, ".apibuilder"))
        ApibuilderCli::Util.write_to_file("#{dir}/.apibuilder/config", """
code:
  apicollective:
    apibuilder:
      version: latest
      generators:
        play_2_3_client: generated/app/ApibuilderClient.scala
      """.strip)
        `git init`
        subdir = File.join(dir, "foo")
        Dir.mkdir(subdir)
        Dir.chdir(subdir)
        app_config = ApibuilderCli::AppConfig.new
        expect(app_config.project_dir).to eq(dir)
      end
    end

    it "should not find the project root when not in the root directory and git is missing" do
      in_tmpdir do |dir|
        Dir.mkdir(File.join(dir, ".apibuilder"))
        ApibuilderCli::Util.write_to_file("#{dir}/.apibuilder/config", """
code:
  apicollective:
    apibuilder:
      version: latest
      generators:
        play_2_3_client: generated/app/ApibuilderClient.scala
      """.strip)
        subdir = File.join(dir, "foo")
        Dir.mkdir(subdir)
        Dir.chdir(subdir)
        expect{ApibuilderCli::AppConfig.new}.to raise_error(SystemExit)
      end
    end
  end

  describe "ApibuilderCli::AppConfig.parse_project_dir" do
    it "should correctly find the project root" do
      expect(ApibuilderCli::AppConfig.parse_project_dir("/src/my-project/.apibuilder/config")).to eq("/src/my-project")
      expect(ApibuilderCli::AppConfig.parse_project_dir("/src/my-project/.foo/.apibuilder/config")).to eq("/src/my-project/.foo")
      expect(ApibuilderCli::AppConfig.parse_project_dir("/src/my-project/.apibuilder/my/buried/config")).to eq("/src/my-project")
      expect(ApibuilderCli::AppConfig.parse_project_dir("/src/my-project/.apibuilder")).to eq("/src/my-project")
      expect(ApibuilderCli::AppConfig.parse_project_dir("/src/my-project/apibuilder.config")).to eq("/src/my-project")
    end
  end

  def in_tmpdir
    Dir.mktmpdir do |dir|
      current_dir = Dir.pwd
      Dir.chdir(dir)
      yield Dir.pwd
      Dir.chdir(current_dir)
    end
  end
end
