load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Config do

  describe "with a valid configuration file" do

    before do
      @sample_file = ApibuilderCli::Util.write_to_temp_file("""
[default]
token = other

[profile public]
token = 

[profile foo]
token = secret-token
      """.strip)
    end

    it "reads file" do
      config = ApibuilderCli::Config.new(:path => @sample_file)
      expect(config.profiles.map(&:name).sort).to eq(["default", "foo", "public"])

      default = config.profiles.find { |p| p.name == "default" }
      expect(default.name).to eq("default")
      expect(default.token).to eq("other")

      pub = config.profiles.find { |p| p.name == "public" }
      expect(pub.name).to eq("public")
      expect(pub.token).to be(nil)

      foo = config.profiles.find { |p| p.name == "foo" }
      expect(foo.name).to eq("foo")
      expect(foo.token).to eq("secret-token")

      expect(config.default_profile).to eq(default)
    end

  end

end
