# Reads the apibuilder CLI configuration file
module ApibuilderCli

  class Settings
    DEFAULT_MAX_THREADS = 10 unless defined?(DEFAULT_MAX_THREADS)
    DEFAULT_TRACKED_FILES_ENABLED = true unless defined?(DEFAULT_TRACKED_FILES_ENABLED)

    attr_reader :max_threads, :tracked_files_enabled

    def initialize(args={})
      all = args.dup

      @max_threads = all.has_key?("max_threads") ? all.delete("max_threads").to_i : DEFAULT_MAX_THREADS
      if @max_threads <= 0
        raise "Invalid setting for max_threads[#{@max_threads}]. Must be > 0"
      end

      @tracked_files_enabled = if all.has_key?("tracked_files_enabled")
        value = all["tracked_files_enabled"]
        all.delete("tracked_files_enabled")
        parse_boolean("tracked_files_enabled", value)
      else
        DEFAULT_TRACKED_FILES_ENABLED
      end

      invalid = all.keys
      if !invalid.empty?
        puts ""
        puts "ERROR: Invalid settings. The following setting(s) are not valid:"
        invalid.each { |k| puts " - #{k}" }
        puts ""
        exit(1)
      end
    end

    private
    def parse_boolean(name, value)
      case value
      when "true"
        then true
      when "false"
        then false
      else
        raise "Invalid value for #{name}[#{value}]. Must be 'true' or 'false'"
      end
    end

  end

end
