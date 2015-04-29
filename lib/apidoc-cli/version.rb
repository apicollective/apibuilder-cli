module ApidocCli

  module Version

    VERSION = '0.0.2' # Automatically updated by util/create-release.rb

    # Writes contents to a temp file, returning the path
    def Version.current
      "#{VERSION}"
    end

  end

end
