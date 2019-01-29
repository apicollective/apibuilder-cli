load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::AppConfig do

  def generator(project, name)
    project.generators.find { |g| g.name == name }
  end

  describe "basic attributes" do

    before do
      @sample_file = ApibuilderCli::Util.write_to_temp_file("""
attributes:
  generators:
    play_2_6_client:
      foo: bar
    other_client:
      a: b

code:
  apicollective:
    apibuilder:
      version: latest
      generators:
        play_2_6_client: generated/app/ApibuilderClient.scala
        other_client: generated/app/OtherClient.scala
        random_client: generated/app/RandomClient.scala
  happycorp:
    salary:
        version: 1.3.5
        generators:
          - generator: play_2_6_client
            target: src/main/generated
            files:
              - HappycorpApiSalaryCalculatorV0Client.scala
          - generator: happy_client
            target: src/test/generated
            attributes:
              foo: baz
            files:
              - HappycorpApiSalaryCalculatorV0MockClient.scala
      """.strip)
    end

    it "reads global generator attributes" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      expect(app_config.attributes.generators.size).to eq(2)
      ga = app_config.attributes.generators.first
      expect(ga.generator_name).to eq("play_2_6_client")
      expect(ga.attributes).to eq({ "foo" => "bar" })

      ga = app_config.attributes.generators.last
      expect(ga.generator_name).to eq("other_client")
      expect(ga.attributes).to eq({ "a" => "b" })
    end

    it "reads local generator attributes" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      apibuilder = app_config.code.projects.find { |p| p.name == "apibuilder" }
      expect(generator(apibuilder, "play_2_6_client").attributes).to eq({ "foo" => "bar" })
      expect(generator(apibuilder, "other_client").attributes).to eq({"a" => "b"})
      expect(generator(apibuilder, "random_client").attributes).to eq({})
    end

    it "supports local override" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      salary = app_config.code.projects.find { |p| p.name == "salary" }
      expect(generator(salary, "play_2_6_client").attributes).to eq({ "foo" => "bar" })
      expect(generator(salary, "happy_client").attributes).to eq({"foo" => "baz"})
    end
  end

  describe "attributes for wildcard generator keys" do

    before do
      @sample_file2 = ApibuilderCli::Util.write_to_temp_file("""
attributes:
  generators:
    play*:
      a: b
    play_client:
      c: d

code:
  apicollective:
    apibuilder:
      version: latest
      generators:
        play_client: generated/app/PlayClient.scala
        play_json: generated/app/PlayJson.scala
        other_client: generated/app/OtherClient.scala
      """.strip)
    end

    it "reads global generator attributes" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file2)
      apibuilder = app_config.code.projects.find { |p| p.name == "apibuilder" }
      expect(generator(apibuilder, "play_client").attributes).to eq({ "a" => "b", "c" => "d" })
      expect(generator(apibuilder, "play_json").attributes).to eq({ "a" => "b" })
      expect(generator(apibuilder, "other_client").attributes).to eq({})
    end

  end
end
