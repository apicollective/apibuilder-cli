module ApibuilderCli

  module Git

    def Git.current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def Git.safe_describe(commits_back = nil)
      head = commits_back.nil? ? "" : "HEAD~#{commits_back}"
      system("git describe #{head} > /dev/null 2>&1") ? `git describe #{head}`.strip : ""
    end

  end

end
