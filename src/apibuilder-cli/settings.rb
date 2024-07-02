# Reads the apibuilder CLI configuration file
module ApibuilderCli

  class Settings
    DEFAULT_MAX_THREADS = 10

    attr_reader :max_threads

    def initialize(args={})
      all = args.dup
      @max_threads = all.has_key?("max_threads") ? all.delete("max_threads").to_i : DEFAULT_MAX_THREADS
      if @max_threads <= 0
        raise "Invalid setting for max_threads[#{@max_threads}]. Must be > 0"
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

  end

end
