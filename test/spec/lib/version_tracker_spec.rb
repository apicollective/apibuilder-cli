load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::VersionTracker do

  before do
    @sample_file = ApibuilderCli::Util.write_to_temp_file("""
apicollective:
  apibuilder: 0.16.53
  apibuilder-spec: 0.16.50
foo:
  bar: 1.2.3
    """.strip)
    @empty_file = ApibuilderCli::Util.write_to_temp_file("")
  end

  it "reads versions from an existing file" do
    tracker = ApibuilderCli::VersionTracker.new("dummy", :path => @sample_file)
    expect(tracker.version("apicollective", "apibuilder")).to eq("0.16.53")
    expect(tracker.version("apicollective", "apibuilder-spec")).to eq("0.16.50")
    expect(tracker.version("foo", "bar")).to eq("1.2.3")
  end

  it "returns nil for unknown org or application" do
    tracker = ApibuilderCli::VersionTracker.new("dummy", :path => @sample_file)
    expect(tracker.version("apicollective", "other")).to be_nil
    expect(tracker.version("other", "apibuilder")).to be_nil
  end

  it "starts empty when the file does not exist or is empty" do
    expect(ApibuilderCli::VersionTracker.new("dummy", :path => "/tmp/does-not-exist-#{Process.pid}").version("a", "b")).to be_nil
    expect(ApibuilderCli::VersionTracker.new("dummy", :path => @empty_file).version("a", "b")).to be_nil
  end

  it "records and overwrites versions" do
    tracker = ApibuilderCli::VersionTracker.new("dummy", :path => @sample_file)
    tracker.set!("apicollective", "apibuilder", "0.16.54")
    tracker.set!("apicollective", "new-app", "0.0.1")
    expect(tracker.version("apicollective", "apibuilder")).to eq("0.16.54")
    expect(tracker.version("apicollective", "new-app")).to eq("0.0.1")
  end

  it "round-trips through save! and preserves untouched entries" do
    tracker = ApibuilderCli::VersionTracker.new("dummy", :path => @sample_file)
    tracker.set!("apicollective", "apibuilder", "0.16.54")
    tracker.save!

    reloaded = ApibuilderCli::VersionTracker.new("dummy", :path => @sample_file)
    expect(reloaded.version("apicollective", "apibuilder")).to eq("0.16.54")
    expect(reloaded.version("apicollective", "apibuilder-spec")).to eq("0.16.50")
    expect(reloaded.version("foo", "bar")).to eq("1.2.3")
  end

  it "writes deterministically sorted output" do
    path = ApibuilderCli::Util.write_to_temp_file("")
    tracker = ApibuilderCli::VersionTracker.new("dummy", :path => path)
    tracker.set!("zed", "zapp", "2.0.0")
    tracker.set!("alpha", "bapp", "1.0.0")
    tracker.set!("alpha", "aapp", "1.0.0")
    tracker.save!
    expect(IO.read(path)).to eq("---\nalpha:\n  aapp: 1.0.0\n  bapp: 1.0.0\nzed:\n  zapp: 2.0.0\n")
  end

  it "ignores an unparseable file and rebuilds from empty" do
    bad = ApibuilderCli::Util.write_to_temp_file("code: [unclosed")
    tracker = nil
    expect { tracker = ApibuilderCli::VersionTracker.new("dummy", :path => bad) }.to output(/WARNING/).to_stdout
    expect(tracker.version("a", "b")).to be_nil
    tracker.set!("a", "b", "1.0.0")
    tracker.save!
    expect(ApibuilderCli::VersionTracker.new("dummy", :path => bad).version("a", "b")).to eq("1.0.0")
  end

end
