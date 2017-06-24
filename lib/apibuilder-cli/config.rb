# Reads the apibuilder CLI configuration file
module ApibuilderCli

  class Config

    DEFAULT_DIRECTORIES = ["~/.apibuilder", "~/.apidoc"] unless defined?(DEFAULT_DIRECTORIES)
    DEFAULT_FILENAME = "config" unless defined?(DEFAULT_FILENAME)
    DEFAULT_API_URI = "https://api.apibuilder.io" unless defined?(DEFAULT_API_URI)
    DEFAULT_PROFILE_NAME = "default"

    def Config.client_from_profile(opts={})
      profile = Preconditions.assert_class_or_nil(opts.delete(:profile), String)
      token = Preconditions.assert_class_or_nil(opts.delete(:token), String)
      Preconditions.assert_empty_opts(opts)

      config = ApibuilderCli::Config.new
      profile_config = profile ? config.profile(profile) : config.default_profile

      if profile_config.nil? && profile
        if profile != DEFAULT_PROFILE_NAME
          if !File.exists?(config.path)
            raise "Profile[#{profile}] not found as configuration file #{config.path} does not exist"
          else
            raise "Profile[#{profile}] not found in configuration file #{config.path}"
          end
        end
      end

      final_token = token || (profile_config ? profile_config.token : nil)
      auth = if final_token
               Io::Apibuilder::Api::V0::HttpClient::Authorization.basic(final_token)
             else
               nil
             end

      api_uri = profile_config ? profile_config.api_uri : DEFAULT_API_URI
      Io::Apibuilder::Api::V0::Client.new(api_uri, :authorization => auth)
    end

    attr_reader :path

    def Config.default_path
      dir = DEFAULT_DIRECTORIES.find { |p| File.directory?(File.expand_path(p)) }
      if dir.nil?
        puts "**ERROR** Could not find apibuilder configuration directory. Expected at: %s" % DEFAULT_DIRECTORIES.first
        exit(1)
      end

      if dir != DEFAULT_DIRECTORIES.first
        puts "******************** WARNING ********************"
        puts "** Directory %s is now deprecated and should be named %s\n** To Fix:\n**   mv %s %s" % [dir, DEFAULT_DIRECTORIES.first, dir, DEFAULT_DIRECTORIES.first]
        puts "*************************************************"
      end

      File.expand_path(File.join(dir, DEFAULT_FILENAME))
    end
      
    def initialize(opts={})
      @path = Preconditions.assert_class(opts.delete(:path) || Config.default_path, String)
      contents = File.exists?(@path) ? IO.readlines(@path) : []

      @profiles = []

      contents.each_with_index do |line, i|
        stripped = line.strip
        if stripped == ""
          next
        end

        if md = stripped.match(/^\[(.+)\]$/)
          parts = md[1].strip.split(/\s+/, 2)
          key = parts[0].to_s.strip
          value = parts[1].to_s.strip
          reading = key

          if key == "profile"
            Preconditions.check_state(value != "", "%s:%s profile attribute missing name" % [@path, i+1])
            Preconditions.check_state(profile(value).nil?, "%s:%s duplicate profile[%s]" % [@path, i+1, value])
          elsif key != "default"
            raise "%s:%s unknown configuration key[%s]" % [@path, i+1, key]
          end

          profile_name = (key == "default") ? "default" : value
          @profiles << Profile.new(profile_name)

        else
          name, value = stripped.split(/\s*=\s*/, 2).map(&:strip)

          if name != "" && value != ""
            @profiles[-1].add(name, value)
          end
        end

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
      profile(DEFAULT_PROFILE_NAME)
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

    attr_reader :name, :api_uri

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

    def api_uri
      @data[:api_uri] || ApibuilderCli::Config::DEFAULT_API_URI
    end

  end

end
