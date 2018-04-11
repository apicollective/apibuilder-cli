require 'digest'

module ApibuilderCli

  module Git

    def Git.branch_suffix(branch)
      "-b#{Git.small_hash(branch)}-#{branch}"
    end

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
        if branch == "master"
          raw_version
        else
          # Include a semi-unique hash to serve as a pseudo-delimiter. When searching
          # for a matching branch, this will prevent too-optimistic matching, i.e. a
          # branch named "dev" matching "my-dev", etc. Also include the actual branch
          # name for readability.
          "#{raw_version}#{Git.branch_suffix(branch)}"
        end
      end
    end

    def Git.safe_describe(commits_back = nil)
      head = commits_back.nil? ? "" : "HEAD~#{commits_back}"
      system("git describe #{head} > /dev/null 2>&1") ? `git describe #{head}`.strip : ""
    end

    def Git.small_hash(str)
      Digest::SHA1.hexdigest(str).slice(0,7)
    end

    def Git.tag_list
      `git tag --list`.strip.split("\n")
    end

  end

end
