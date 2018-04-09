module ApibuilderCli

  module Git

    def Git.safe_describe(commits_back = nil)
      head = commits_back.nil? ? "" : "HEAD~#{commits_back}"
      system("git describe #{head} 2> /dev/null") ? `git describe #{head}`.strip : ""
    end

  end

end
