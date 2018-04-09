load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Git do

  describe "#safe_describe" do

    it "should work for tagged repos" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        tag = ApibuilderCli::Git.safe_describe
        expect(tag).to eq "0.0.1"
      end
    end

    it "should work for untagged" do
      with_repo do |dir|
        tag = ApibuilderCli::Git.safe_describe
        expect(tag).to eq ""
      end
    end

    it "should work for untagged commits after a tag" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        tag = ApibuilderCli::Git.safe_describe
        expect(tag).to match /0\.0\.1-1-g[0-9a-f]{7}/
      end
    end

    it "should work for previous commits" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        system("touch temp3.txt; git add temp3.txt; git commit -m 'Third commit' &> /dev/null")
        expect(ApibuilderCli::Git.safe_describe).to eq ApibuilderCli::Git.safe_describe(0)
        tag = ApibuilderCli::Git.safe_describe
        expect(tag).to match /0\.0\.1-2-g[0-9a-f]{7}/
        tag = ApibuilderCli::Git.safe_describe(1)
        expect(tag).to match /0\.0\.1-1-g[0-9a-f]{7}/
        tag = ApibuilderCli::Git.safe_describe(2)
        expect(tag).to eq "0.0.1"
      end
    end

  end

end

def with_repo()
  Dir.mktmpdir do |dir|
    Dir.chdir(dir)
    system("git init &> /dev/null")
    system("touch temp.txt; git add temp.txt; git commit -m 'Initial commit' &> /dev/null")
    yield dir
  end
end