load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApidocCli::Config do

  describe "with a valid configuration file" do

    before do
      @sample_file = ApidocCli::Util.write_to_temp_file("""
[default]
profile = public

[profile public]
token = 

[profile foo]
token = secret-token
      """.strip)
    end

    it "reads file" do
      config = ApidocCli::Config.new(:path => @sample_file)
      expect(config.profiles.map(&:name).sort).to eq(["foo", "public"])

      pub = config.profiles.find { |p| p.name == "public" }
      expect(pub.name).to eq("public")
      expect(pub.token).to be(nil)

      foo = config.profiles.find { |p| p.name == "foo" }
      expect(foo.name).to eq("foo")
      expect(foo.token).to eq("secret-token")

      expect(config.default_profile).to eq(pub)
    end

  end

  describe "with an invalid default profile" do

    before do
      @sample_file = ApidocCli::Util.write_to_temp_file("""
[default]
profile = foo

[profile public]
token = 
      """.strip)
    end

    it "raises error on invalid default" do
      expect {
        ApidocCli::Config.new(:path => @sample_file)
      }.to raise_error(RuntimeError, "Default profile[foo] is not defined")
    end


  end

end
