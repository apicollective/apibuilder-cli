# Reads the apidoc CLI configuration file
module ApidocCli

  class Config

    DEFAULT_PROFILE = "default" unless defined?(DEFAULT_PROFILE)
    DEFAULT_PATH = "~/.apidoc/config" unless defined?(DEFAULT_PATH)

    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || File.expand_path(DEFAULT_PATH), String)
      Preconditions.check_state(File.exists?(@path), "Apidoc CLI config file[#{@path}] not found")

      reading = nil
      @default = nil
      @profiles = []

      IO.readlines(@path).each_with_index do |line, i|
        stripped = line.strip
        if stripped == ""
          next
        end

        if md = stripped.match(/^\[(.+)\]$/)
          parts = md[1].strip.split(/\s+/, 2)
          key = parts[0].to_s.strip
          value = parts[1].to_s.strip
          reading = key

          if key == "default"
            Preconditions.check_state(value == "", "%s:%s value attribute[%s] not supported for key default" % [@path, i+1, value])
            @default = Default.new

          elsif key == "profile"
            Preconditions.check_state(value != "", "%s:%s profile attribute missing name" % [@path, i+1])
            Preconditions.check_state(profile(value).nil?, "%s:%s duplicate profile[%s]" % [@path, i+1, value])
            @profiles << Profile.new(value)

          else
            raise "%s:%s unknown configuration key[%s]" % [@path, i+1, key]
          end

        else
          name, value = stripped.split(/\s*=\s*/, 2).map(&:strip)

          if name != "" && value != ""
            if reading == "default"
              @default.add(name, value)
            elsif reading == "profile"
              @profiles[-1].add(name, value)
            end
          end
        end

      end

      if @default && profile(@default.profile).nil?
        raise "Default profile[#{@default.profile}] is not defined"
      end
    end

    # returns a sorted list of the profile
    def profiles
      @profiles.sort_by(&:name)
    end

    # Returns the Profile instance w/ the specified name
    def profile(name)
      @profiles.find { |p| p.name == name }
    end

    def default_profile
      if @default
        profile(@default.profile)
      else
        nil
      end
    end

  end

  class Default

    def initialize
      @data = {}
    end

    def add(key, value)
      Preconditions.assert_class(key, String)
      Preconditions.assert_class(value, String)
      Preconditions.check_state(!@data.has_key?(key), "Profile[#{@name}] duplicate key[#{key}]")

      @data[key.to_sym] = value
    end

    def profile
      @data[:profile]
    end

  end

  class Profile

    attr_reader :name

    def initialize(name)
      @name = Preconditions.assert_class(name, String)
      @data = {}
    end

    def add(key, value)
      Preconditions.assert_class(key, String)
      Preconditions.assert_class(value, String)
      Preconditions.check_state(!@data.has_key?(key), "Profile[#{@name}] duplicate key[#{key}]")
      Preconditions.check_state(key != "name", "Name is a reserved word")

      @data[key.to_sym] = value
    end

    def token
      @data[:token]
    end

  end

end
