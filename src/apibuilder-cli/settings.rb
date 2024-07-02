# Reads the apibuilder CLI configuration file
module ApibuilderCli

  class Settings
    DEFAULT_MAX_THREADS = 10
    DEFAULT_TRACKED_FILES_ENABLED = true

    attr_reader :max_threads, :tracked_files_enabled

    def initialize(args={})
      all = args.dup

      @max_threads = all.has_key?("max_threads") ? all.delete("max_threads").to_i : DEFAULT_MAX_THREADS
      if @max_threads <= 0
        raise "Invalid setting for max_threads[#{@max_threads}]. Must be > 0"
      end

      @tracked_files_enabled = all.has_key?("tracked_files_enabled") ? (all.delete("tracked_files_enabled") ? true : false) : DEFAULT_TRACKED_FILES_ENABLED

      invalid = all.keys
      if !invalid.empty?
        puts ""
        puts "ERROR: Invalid settings. The following setting(s) are not valid:"
        invalid.each { |k| puts " - #{k}" }
        puts ""
        exit(1)
      end
    end

  end

end
