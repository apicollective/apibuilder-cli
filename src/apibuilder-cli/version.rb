module ApibuilderCli

  module Version

    VERSION = '0.1.18' # Automatically updated by util/create-release.rb

    # Writes contents to a temp file, returning the path
    def Version.current
      "#{VERSION}"
    end

    def Version.latest
      url = 'https://api.github.com/repos/apicollective/apibuilder-cli/tags?per_page=1'
      version = if result = `curl --silent "#{url}"`.strip
                  if hash = JSON.parse(result).first
                    if hash.is_a?(Hash)
                      hash['name']
                    end
                  end
                end

      if version
        version
      else
        raise "ERROR: Failed to fetch version version from URI: #{url}\n#{result}"
      end
    end

  end

end
