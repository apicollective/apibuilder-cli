load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::FileTracker do

  before do
    @sample_file = ApibuilderCli::Util.write_to_temp_file("""
apicollective:
  apibuilder:
    play_2_3_client:
    - generated/app/ApibuilderClient.scala
    play_2_x_routes:
    - api/conf/routes
  apibuilder-spec:
    play_2_3_client:
    - generated/app/ApibuilderSpec.scala
foo:
  bar:
    ruby_client:
    - /tmp/client.rb
    """.strip)
    @empty_destination = ApibuilderCli::Util.write_to_temp_file("")
  end

  [true, false].each do |is_empty|
    describe "with #{is_empty ? "no" : "some"} files tracked" do

      before do
        @file_path = is_empty ? @empty_destination : @sample_file
        @files = ApibuilderCli::FileTracker.new(:path => @file_path)
        @previous_count = @files.to_cleanup.size
      end

      it "loads the previous list correctly" do
        expect(@files.to_cleanup.empty?).to be is_empty
      end

      it "can track files" do
        @files.track!("baz", "bar", "ruby_client", "new_file1.rb")
        @files.track!("baz", "bar", "ruby_client", "new_file2.rb")
        expect(@files.to_cleanup.size).to be @previous_count
      end

      it "can save tracked files" do
        @files.track!("baz", "bar", "ruby_client", "new_file1.rb")
        @files.track!("baz", "bar", "ruby_client", "new_file2.rb")
        @files.save!
        expect(IO.read(@file_path)).to eq """---
baz:
  bar:
    ruby_client:
    - new_file1.rb
    - new_file2.rb
"""
      end

    end
  end

  describe "with some files tracked" do

    before do
      @files = ApibuilderCli::FileTracker.new(:path => @sample_file)
    end

    describe "#save" do

      it "should not duplicate files" do
        @files.track!("apicollective", "apibuilder", "play_2_x_routes", "api/conf/routes")
        @files.track!("apicollective", "apibuilder", "play_2_x_routes", "api/conf/routes")
        @files.save!
        expect(IO.read(@sample_file)).to eq """---
apicollective:
  apibuilder:
    play_2_x_routes:
    - api/conf/routes
"""
      end

      it "should sort files" do
        @files.track!("apicollective", "apibuilder", "play_2_x_routes", "routes")
        @files.track!("apicollective", "apibuilder", "play_2_x_routes", "api/conf/routes")
        @files.save!
        expect(IO.read(@sample_file)).to eq """---
apicollective:
  apibuilder:
    play_2_x_routes:
    - api/conf/routes
    - routes
"""
      end

    end

    describe "#to_cleanup" do

      it "should flatten files across org/project/generator" do
        expect(@files.to_cleanup).to match_array ["/tmp/client.rb", "api/conf/routes", "generated/app/ApibuilderClient.scala", "generated/app/ApibuilderSpec.scala"]
      end

      it "should not list files used by other org/project/generator" do
        @files.track!("apicollective", "apibuilder", "play_2_x_routes", "/tmp/client.rb")
        expect(@files.to_cleanup).to match_array ["api/conf/routes", "generated/app/ApibuilderClient.scala", "generated/app/ApibuilderSpec.scala"]
      end

      it "should remove current files" do
        @files.track!("apicollective", "apibuilder", "play_2_x_routes", "api/conf/routes")
        @files.track!("apicollective", "apibuilder", "play_2_3_client", "generated/app/ApibuilderClient.scala")
        expect(@files.to_cleanup).to match_array ["/tmp/client.rb", "generated/app/ApibuilderSpec.scala"]
      end

    end

  end

end
