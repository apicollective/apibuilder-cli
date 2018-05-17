require 'digest'

module ApibuilderCli

  module Git

    def Git.branch_suffix(branch)
      "-b#{Git.small_hash(branch)}-#{branch}"
    end

    def Git.checkout(branch)
      `git checkout #{branch}`
    end

    def Git.current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def Git.num_commits
      `git rev-list --count HEAD`.strip.to_i
    end

    def Git.generate_version(commits_back = nil)
      res = Git.generate_versions(commits_back.nil? ? [] : [commits_back])
      if !res.empty?
        res[0]
      else
        ''
      end
    end

    def Git.generate_versions(commits_back = [])
      raw_versions = Git.safe_describe(commits_back)
      if raw_versions == []
        []
      else
        branch = Git.current_branch.downcase
        if branch == "master"
          raw_versions
        else
          # Include a semi-unique hash to serve as a pseudo-delimiter. When searching
          # for a matching branch, this will prevent too-optimistic matching, i.e. a
          # branch named "dev" matching "my-dev", etc. Also include the actual branch
          # name for readability.
          raw_versions.map { |v| "#{v}#{Git.branch_suffix(branch)}" }
        end
      end
    end

    def Git.in_branch(branch)
      current_branch = ApibuilderCli::Git.current_branch
      ApibuilderCli::Git.checkout(branch) unless current_branch == branch
      begin
        yield
      ensure
        ApibuilderCli::Git.checkout(current_branch) unless ApibuilderCli::Git.current_branch == current_branch
      end
    end

    def Git.safe_describe(commits_back = nil)
      heads = (commits_back.nil? ? [] : commits_back.map { |n| "HEAD~#{n}" }).join(' ')
      system("git describe #{heads} > /dev/null 2>&1") ? `git describe #{heads}`.strip.split("\n") : []
    end

    def Git.small_hash(str)
      Digest::SHA1.hexdigest(str).slice(0, 7)
    end

    def Git.tag_list
      `git tag --list`.strip.split("\n")
    end

  end

end
