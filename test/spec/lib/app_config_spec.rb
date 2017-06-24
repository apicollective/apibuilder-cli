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

  foo:
    bar:
      version: 0.0.1
      generators:
        ruby_client: /tmp/client.rb
      """.strip)
    end

    it "reads file" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      expect(app_config.code.projects.map(&:name).sort).to eq(["apibuilder", "apibuilder-generator", "apibuilder-spec", "bar"])

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
    end

  end

end
