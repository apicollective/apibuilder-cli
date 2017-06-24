load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Args do

  it "with empty args" do
    args = ApibuilderCli::Args.parse([])
    expect(args.empty?).to be true
  end

  it "with no flags args" do
    args = ApibuilderCli::Args.parse(["foo"])
    expect(args.empty?).to be true
  end

  it "with no flags args" do
    args = ApibuilderCli::Args.parse(["--organization", "foo"])
    expect(args.keys.join(" ")).to eq("organization")
    expect(args[:organization]).to eq("foo")
  end

  it "with multiple args" do
    args = ApibuilderCli::Args.parse(["--organization", "foo", "--path", "bar", "baz"])
    expect(args.keys.map(&:to_s).sort.join(" ")).to eq("organization path")
    expect(args[:organization]).to eq("foo")
    expect(args[:path]).to eq("bar")
  end

  it "args without values" do
    pairs = [
             ["--force", "--organization", "foo"],
             ["--organization", "foo", "--force"]
            ]
    pairs.each do |p|
      args = ApibuilderCli::Args.parse(p)
      expect(args.keys.map(&:to_s).sort.join(" ")).to eq("force organization")
      expect(args[:organization]).to eq("foo")
      expect(args[:force]).to be_nil
    end
  end

end
