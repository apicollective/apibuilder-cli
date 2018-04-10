module ApibuilderCli

  module Git

    def Git.current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def Git.generate_version(commits_back = nil, legacy = false)
      raw_version = Git.safe_describe(commits_back)
      if raw_version == ""
        ""
      elsif legacy
        raw_version
      else
        branch = Git.current_branch.downcase
        suffix = branch == "master" ? "" : "-#{branch}"
        "#{raw_version}#{suffix}"
      end
    end

    def Git.safe_describe(commits_back = nil)
      head = commits_back.nil? ? "" : "HEAD~#{commits_back}"
      system("git describe #{head} > /dev/null 2>&1") ? `git describe #{head}`.strip : ""
    end

    def Git.tag_list
      `git tag --list`.strip.split("\n")
    end

  end

end
