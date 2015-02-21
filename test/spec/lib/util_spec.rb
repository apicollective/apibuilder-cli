load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApidocCli::Util do

  it "Util.write_to_temp_file" do
    path = ApidocCli::Util.write_to_temp_file("foo")
    expect(IO.read(path)).to eq("foo")
  end

  it "Util.write_to_file" do
    path = "/tmp/apidoc-cli.test.tmp"
    ApidocCli::Util.write_to_file(path, "foo")
    expect(IO.read(path)).to eq("foo")
    File.delete(path)
  end

  it "Util.read_non_empty_string" do
    expect(ApidocCli::Util.read_non_empty_string("  foo  ")).to eq("foo")
    expect(ApidocCli::Util.read_non_empty_string("    ")).to be(nil)
  end

  it "Util.read_non_empty_integer" do
    expect(ApidocCli::Util.read_non_empty_integer("  5  ")).to eq(5)
    expect(ApidocCli::Util.read_non_empty_integer("    ")).to be(nil)
    expect(ApidocCli::Util.read_non_empty_integer("  s  ")).to be(nil)
  end

  it "Util.mask" do
    expect(ApidocCli::Util.mask("abcde")).to eq("XXX-XXXX-XXXX")
    expect(ApidocCli::Util.mask("abcdefghijabcdefghijabcdefghij")).to eq("abc-XXXX-ghij")
  end

end
