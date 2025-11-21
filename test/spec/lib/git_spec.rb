load File.join(File.dirname(__FILE__), '../../init.rb')

describe ApibuilderCli::Git do

  describe "#branch_suffix" do

    it "should work" do
      expect(ApibuilderCli::Git.branch_suffix("my-branch")).to eq "-b663c692-my-branch"
    end

  end

  describe "#checkout" do

    it "should work" do
      with_repo do |dir|
        system_quiet("git checkout -b other")
        ApibuilderCli::Git.checkout("main")
        expect(ApibuilderCli::Git.current_branch).to eq "main"
        ApibuilderCli::Git.checkout("other")
        expect(ApibuilderCli::Git.current_branch).to eq "other"
      end
    end

  end

  describe "#safe_describe" do

    it "should work for tagged repos" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        tag = ApibuilderCli::Git.safe_describe
        expect(tag[0]).to eq "0.0.1"
      end
    end

    it "should work for untagged" do
      with_repo do |dir|
        tag = ApibuilderCli::Git.safe_describe
        expect(tag).to eq []
      end
    end

    it "should work for untagged commits after a tag" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        tag = ApibuilderCli::Git.safe_describe
        expect(tag[0]).to match /0\.0\.1-1-g[0-9a-f]{7}/
      end
    end

    it "should work for previous commits" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        system("touch temp3.txt; git add temp3.txt; git commit -m 'Third commit' &> /dev/null")
        system("touch temp4.txt; git add temp4.txt; git commit -m 'Fourth commit' &> /dev/null")
        system("git tag -a 0.0.2 -m 'Second tag'")
        system("touch temp5.txt; git add temp5.txt; git commit -m 'Fifth commit' &> /dev/null")
        expect(ApibuilderCli::Git.safe_describe).to eq ApibuilderCli::Git.safe_describe([0])
        tags = ApibuilderCli::Git.safe_describe(0.upto(4))
        expect(tags.length).to eq 5
        expect(tags[0]).to match /0\.0\.2-1-g[0-9a-f]{7}/
        expect(tags[1]).to eq "0.0.2"
        expect(tags[2]).to match /0\.0\.1-2-g[0-9a-f]{7}/
        expect(tags[3]).to match /0\.0\.1-1-g[0-9a-f]{7}/
        expect(tags[4]).to eq "0.0.1"
      end
    end

  end

  describe "#current_branch" do

    it "should detect main" do
      with_repo do |dir|
        expect(ApibuilderCli::Git.current_branch).to eq "main"
      end
    end

    it "should detect other" do
      with_repo do |dir|
        system_quiet("git checkout -b other")
        expect(ApibuilderCli::Git.current_branch).to eq "other"
      end
    end

    it "should detect main when other exists" do
      with_repo do |dir|
        system_quiet("git checkout -b other; git checkout main")
        expect(ApibuilderCli::Git.current_branch).to eq "main"
      end
    end

  end

  describe "#generate_version" do

    it "should work for tagged repos" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        version = ApibuilderCli::Git.generate_version
        expect(version).to eq "0.0.1"
      end
    end

    it "should work for tagged repos on other branch" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system_quiet("git checkout -b other")
        version = ApibuilderCli::Git.generate_version
        expect(version).to eq "0.0.1-bd0941e6-other"
      end
    end

    it "should work for untagged" do
      with_repo do |dir|
        version = ApibuilderCli::Git.generate_version
        expect(version).to eq ""
      end
    end

    it "should work for untagged on other branch" do
      with_repo do |dir|
        system_quiet("git checkout -b other")
        version = ApibuilderCli::Git.generate_version
        expect(version).to eq ""
      end
    end

    it "should work for untagged commits after a tag" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        version = ApibuilderCli::Git.generate_version
        expect(version).to match /^0\.0\.1-1-g[0-9a-f]{7}$/
      end
    end

    it "should work for untagged commits after a tag on other branch" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system_quiet("git checkout -b other")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        version = ApibuilderCli::Git.generate_version
        expect(version).to match /^0\.0\.1-1-g[0-9a-f]{7}-bd0941e6-other$/
      end
    end

    it "should work for previous commits" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        system("touch temp3.txt; git add temp3.txt; git commit -m 'Third commit' &> /dev/null")
        expect(ApibuilderCli::Git.generate_version).to eq ApibuilderCli::Git.generate_version(0)
        version = ApibuilderCli::Git.generate_version
        expect(version).to match /^0\.0\.1-2-g[0-9a-f]{7}$/
        version = ApibuilderCli::Git.generate_version(1)
        expect(version).to match /^0\.0\.1-1-g[0-9a-f]{7}$/
        version = ApibuilderCli::Git.generate_version(2)
        expect(version).to eq "0.0.1"
      end
    end

    it "should work for previous commits on other branch" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system_quiet("git checkout -b other")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        system("touch temp3.txt; git add temp3.txt; git commit -m 'Third commit' &> /dev/null")
        expect(ApibuilderCli::Git.generate_version).to eq ApibuilderCli::Git.generate_version(0)
        version = ApibuilderCli::Git.generate_version
        expect(version).to match /^0\.0\.1-2-g[0-9a-f]{7}-bd0941e6-other$/
        version = ApibuilderCli::Git.generate_version(1)
        expect(version).to match /^0\.0\.1-1-g[0-9a-f]{7}-bd0941e6-other$/
        version = ApibuilderCli::Git.generate_version(2)
        expect(version).to eq "0.0.1-bd0941e6-other"
      end
    end

  end

  describe "#in_branch" do

    it "should switch to the branch and switch back" do
      with_repo do |dir|
        system_quiet("git checkout -b other")
        expect(ApibuilderCli::Git.current_branch).to eq "other"
        ApibuilderCli::Git.in_branch("main") do
          expect(ApibuilderCli::Git.current_branch).to eq "main"
        end
        expect(ApibuilderCli::Git.current_branch).to eq "other"
      end
    end

    it "should not switch when already on the branch" do
      with_repo do |dir|
        system_quiet("git checkout -b other")
        expect(ApibuilderCli::Git.current_branch).to eq "other"
        ApibuilderCli::Git.in_branch("other") do
          expect(ApibuilderCli::Git.current_branch).to eq "other"
        end
        expect(ApibuilderCli::Git.current_branch).to eq "other"
      end
    end

    it "should switch back even when there is an exception" do
      with_repo do |dir|
        system_quiet("git checkout -b other")
        expect(ApibuilderCli::Git.current_branch).to eq "other"
        begin
          ApibuilderCli::Git.in_branch("main") do
            raise "error"
          end
        rescue Exception => e
        end
        expect(ApibuilderCli::Git.current_branch).to eq "other"
      end
    end

  end

  describe "#small_hash" do

    it "should work" do
      expect(ApibuilderCli::Git.small_hash("foo")).to eq "0beec7b"
    end

    it "should be the correct length" do
      1.upto(50).each do
        expect(ApibuilderCli::Git.small_hash(rand(10000).to_s).size).to eq 7
      end
    end

  end

  describe "#tag_list" do

    it "should work for tagged repos" do
      with_repo do |dir|
        system("git tag -a 0.0.1 -m 'Initial tag'")
        system("touch temp2.txt; git add temp2.txt; git commit -m 'Second commit' &> /dev/null")
        system("git tag -a 0.0.2 -m 'Initial tag'")
        tags = ApibuilderCli::Git.tag_list
        expect(tags).to eq ["0.0.1", "0.0.2"]
      end
    end

    it "should work for repos with no tags" do
      with_repo do |dir|
        tags = ApibuilderCli::Git.tag_list
        expect(tags).to eq []
      end
    end

  end

end

def system_quiet(cmd)
  quiet = " > /dev/null 2>&1"
  system(cmd.gsub(";", "#{quiet};") + quiet)
end

def with_repo()
  current_dir = Dir.pwd
  Dir.mktmpdir do |dir|
    begin
      Dir.chdir(dir)
      system("git init &> /dev/null")
      system("touch temp.txt; git add temp.txt; git commit -m 'Initial commit' &> /dev/null")
      yield dir
    ensure
      Dir.chdir(current_dir)
    end
  end
end
