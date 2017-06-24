#!/usr/bin/env ruby

module ApibuilderCli

  module Args

    # Simple command line argument parsers to avoid pulling in external
    # dependency. Returns a hash
    #
    # Example: ["--organization", "foo"]
    #  returns: { :organization => "foo" }
    def Args.parse(values)
      args = {}

      index = 0
      while index < values.size do
        arg = values[index]
        if md = arg.match(/^\-\-(.+)/)
          name = md[1].to_s.strip
          value = values[index+1].to_s.strip

          if value.match(/^\-\-(.+)/)
            args[name.to_sym] = nil
          else
            index += 1
            if value == ""
              args[name.to_sym] = nil
            else
              args[name.to_sym] = value
            end
          end
        end
        index += 1
      end

      args
    end

  end

end
