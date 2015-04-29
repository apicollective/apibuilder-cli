module ApidocCli

  module Version

    VERSION = '0.0.1' # Updated automatically by util/create-release.rb

    # Writes contents to a temp file, returning the path
    def Version.current
      "#{VERSION}"
    end

  end

end
