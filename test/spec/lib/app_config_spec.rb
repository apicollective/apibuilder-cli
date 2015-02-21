load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApidocCli::AppConfig do

  describe ApidocCli::AppConfig::Generator do

    it "constructor" do
      g = ApidocCli::AppConfig::Generator.new("ruby_client", "/tmp/client.rb")
      expect(g.name).to eq("ruby_client")
      expect(g.target).to eq("/tmp/client.rb")
    end

  end

  describe ApidocCli::AppConfig::Project do

    it "constructor" do
      generators = [ApidocCli::AppConfig::Generator.new("ruby_client", "/tmp/client.rb")]

      project = ApidocCli::AppConfig::Project.new("gilt", "apidoc", generators)
      expect(project.org).to eq("gilt")
      expect(project.name).to eq("apidoc")
      expect(project.generators.map(&:name)).to eq(["ruby_client"])
    end

  end

  describe ApidocCli::AppConfig do

    before do
      @sample_file = ApidocCli::Util.write_to_temp_file("""
gilt:
  apidoc:
    play_2_3_client: generated/app/ApidocClient.scala
    play_2_x_routes: api/conf/routes
  apidoc-spec:
    play_2_3_client: generated/app/ApidocSpec.scala
  apidoc-generator:
    play_2_3_client: generated/app/ApidocGenerator.scala

foo:
  bar:
    ruby_client: /tmp/client.rb
      """.strip)
    end

    it "reads file" do
      app_config = ApidocCli::AppConfig.new(:path => @sample_file)
      expect(app_config.projects.map(&:name).sort).to eq(["apidoc", "apidoc-generator", "apidoc-spec", "bar"])

      apidoc = app_config.projects.find { |p| p.name == "apidoc" }
      expect(apidoc.org).to eq("gilt")
      expect(apidoc.name).to eq("apidoc")
      expect(apidoc.generators.map(&:name).sort).to eq(["play_2_3_client", "play_2_x_routes"])

      bar = app_config.projects.find { |p| p.name == "bar" }
      expect(bar.org).to eq("foo")
      expect(bar.name).to eq("bar")
      expect(bar.generators.map(&:name).sort).to eq(["ruby_client"])
    end

  end

end
