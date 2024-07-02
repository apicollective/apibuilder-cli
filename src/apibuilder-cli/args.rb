module ApibuilderCli

  module Args

    # Simple command line argument parsers to avoid pulling in external
    # dependency. Returns a hash
    #
    # Example: ["--org", "foo"]
    #  returns: { :org => "foo" }
    #
    # Example: Arg.parse(["--app", "foo", "--app", "bar"], :multi => ['app'])
    #  returns: { :app => ["foo", "bar"] }
    def Args.parse(values, config = {})
      multi = (config.delete(:multi) || []).map(&:to_sym)
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
            value = nil if value.empty?
            if multi.include?(name.to_sym)
              args[name.to_sym] ||= []
              args[name.to_sym] << value
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
