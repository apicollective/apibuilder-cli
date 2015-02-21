load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApidocCli::Args do

  it "with empty args" do
    args = ApidocCli::Args.parse([])
    expect(args.empty?).to be true
  end

  it "with no flags args" do
    args = ApidocCli::Args.parse(["foo"])
    expect(args.empty?).to be true
  end

  it "with no flags args" do
    args = ApidocCli::Args.parse(["--organization", "foo"])
    expect(args.keys.join(" ")).to eq("organization")
    expect(args[:organization]).to eq("foo")
  end

  it "with multiple args" do
    args = ApidocCli::Args.parse(["--organization", "foo", "--path", "bar", "baz"])
    expect(args.keys.map(&:to_s).sort.join(" ")).to eq("organization path")
    expect(args[:organization]).to eq("foo")
    expect(args[:path]).to eq("bar")
  end

end
