# Reads the apidoc CLI configuration file
module ApidocCli

  class Config

    DEFAULT_PROFILE = "default" unless defined?(DEFAULT_PROFILE)
    DEFAULT_PATH = "~/.apidoc-cli/config" unless defined?(DEFAULT_PATH)

    attr_reader :default

    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || File.expand_path(DEFAULT_PATH), String)
      Preconditions.check_state(File.exists?(@path), "Apidoc CLI config file[#{@path}] not found")

      reading = nil
      organization = nil
      @default = Default.new
      @organizations = {}

      IO.readlines(@path).each_with_index do |line, i|
        stripped = line.strip
        if stripped == ""
          next
        end

        if md = stripped.match(/^\[(.+)\]$/)
          key, value = md[1].strip.split(/\s+/, 2).map(&:strip)
          reading = key

          if key == "default"
            Preconditions.check_state(value.to_s == "", "%s:%s value attribute[%s] not supported for key default" % [@path, i+1, value])
            @default = Default.new

          elsif key == "organization"
            Preconditions.check_state(value.to_s != "", "%s:%s organization attribute missing name" % [@path, i+1])
            Preconditions.check_state(!@organizations.has_key?(value), "%s:%s duplicate organization[%s]" % [@path, i+1, value])
            organization = Organization.new(value)
            @organizations[value] = organization

          else
            raise "%s:%s unknown configuration key[%s]" % [@path, i+1, key]
          end

        else
          name, value = stripped.split(/\s*=\s*/, 2).map(&:strip)

          if name && value
            if reading == "default"
              @default.add(name, value)
            elsif reading == "organization"
              organization.add(name, value)
            end
          end
        end

      end
    end

    # returns a sorted list of the organization
    def organizations
      @organizations.keys.sort(&:name).map do |name|
        @organizations[name]
      end
    end

    # Returns the Organization instance w/ the specified name
    def organization(organization)
      Preconditions.assert_class(organization, String)
      Preconditions.check_not_null(@organizations[organization], "Organization[#{organization}] not found")
    end

  end

  class Default

    def initialize
      @data = {}
    end

    def add(key, value)
      Preconditions.assert_class(key, String)
      Preconditions.assert_class(value, String)
      Preconditions.check_state(!@data.has_key?(key), "Organization[#{@name}] duplicate key[#{key}]")

      @data[key.to_sym] = value
    end

    def organization
      @data[:organization]
    end

  end

  class Organization

    attr_reader :name

    def initialize(name)
      @name = Preconditions.assert_class(name, String)
      @data = {}
    end

    def add(key, value)
      Preconditions.assert_class(key, String)
      Preconditions.assert_class(value, String)
      Preconditions.check_state(!@data.has_key?(key), "Organization[#{@name}] duplicate key[#{key}]")
      Preconditions.check_state(key != "name", "Name is a reserved word")

      @data[key.to_sym] = value
    end

    def token
      @data[:token]
    end

  end

end
