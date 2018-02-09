load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Util do

  describe "Util.file_join" do
    it "should eliminate nils" do
      expect(ApibuilderCli::Util.file_join(nil, "foo", "bar")).to eq("foo/bar")
    end

    it "should eliminate empty strings" do
      expect(ApibuilderCli::Util.file_join("", "foo", "bar")).to eq("foo/bar")
      expect(ApibuilderCli::Util.file_join("  ", "foo", "bar")).to eq("foo/bar")
    end
  end

  it "Util.write_to_temp_file" do
    path = ApibuilderCli::Util.write_to_temp_file("foo")
    expect(IO.read(path)).to eq("foo")
  end

  it "Util.write_to_file" do
    path = "/tmp/apibuilder-cli.test.tmp"
    ApibuilderCli::Util.write_to_file(path, "foo")
    expect(IO.read(path)).to eq("foo")
    File.delete(path)
  end

  it "Util.read_non_empty_string" do
    expect(ApibuilderCli::Util.read_non_empty_string("  foo  ")).to eq("foo")
    expect(ApibuilderCli::Util.read_non_empty_string("    ")).to be(nil)
  end

  it "Util.read_non_empty_integer" do
    expect(ApibuilderCli::Util.read_non_empty_integer("  5  ")).to eq(5)
    expect(ApibuilderCli::Util.read_non_empty_integer("    ")).to be(nil)
    expect(ApibuilderCli::Util.read_non_empty_integer("  s  ")).to be(nil)
  end

  it "Util.mask" do
    expect(ApibuilderCli::Util.mask("abcde")).to eq("XXX-XXXX-XXXX")
    expect(ApibuilderCli::Util.mask("abcdefghijabcdefghijabcdefghij")).to eq("abc-XXXX-ghij")
  end

end
