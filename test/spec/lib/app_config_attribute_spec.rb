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
  happycorp:
    api-salary-calculator:
        version: 1.3.5
        generators:
          - generator: play_2_6_client
            target: src/main/generated
            files:
              - HappycorpApiSalaryCalculatorV0Client.scala
          - generator: play_2_6_client
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
      expect(ga.generator_key).to eq("play_2_6_client")
      expect(ga.attributes).to eq({ "foo" => "bar" })

      ga = app_config.generator_attributes.last
      expect(ga.generator_key).to eq("other_client")
      expect(ga.attributes).to eq({ "a" => "b" })
    end
  end

end
