#!/usr/bin/env ruby

module ApidocCli

  module Args

    # Simple command line argument parsers to avoid pulling in external
    # dependency. Returns a hash
    #
    # Example: "--organization foo"
    #  returns: { :organization => "foo" }
    def Args.parse(value)
      args = {}

      index = 0
      while index < ARGV.size do
        arg = ARGV[index]
        if md = arg.match(/^\-\-(.+)/)
          name = md[1].to_s.strip
          value = ARGV[index+1].to_s.strip
          index += 1
          if value != ""
            args[name.to_sym] = value
          end
        end
        index += 1
      end

      args
    end

  end

end
