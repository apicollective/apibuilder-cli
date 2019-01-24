load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::AppConfig do

  describe ApibuilderCli::AppConfig do

    before do
      @sample_file = ApibuilderCli::Util.write_to_temp_file("""
generator_attributes:
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
      expect(app_config.generator_attributes.size).to eq(2)
      ga = app_config.generator_attributes.first
      expect(ga.generator_name).to eq("play_2_6_client")
      expect(ga.attributes).to eq({ "foo" => "bar" })

      ga = app_config.generator_attributes.last
      expect(ga.generator_name).to eq("other_client")
      expect(ga.attributes).to eq({ "a" => "b" })
    end

    def generator(project, name)
      project.generators.find { |g| g.name == name }
    end

    it "reads local generator attributes" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      puts app_config.code.projects.inspect
      apicollective = app_config.code.projects.find { |p| p.name == "apibuilder" }
      expect(generator(apicollective, "play_2_6_client").attributes).to eq({ "foo" => "bar" })
      expect(generator(apicollective, "other_client").attributes).to eq({"a" => "b"})
      expect(generator(apicollective, "random_client").attributes).to eq({})
    end

    it "supports local override" do
      app_config = ApibuilderCli::AppConfig.new(:path => @sample_file)
      puts app_config.code.projects.inspect
      apicollective = app_config.code.projects.find { |p| p.name == "salary" }
      expect(generator(apicollective, "play_2_6_client").attributes).to eq({ "foo" => "bar" })
      expect(generator(apicollective, "happy_client").attributes).to eq({"foo" => "baz"})
    end
  end

end
