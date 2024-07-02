
module ApibuilderCli
  module Ask
    def Ask.for_hidden
      settings = `stty -g`.strip
      begin
        `stty -echo`
        input = STDIN.gets
        puts ""
      ensure
        `stty #{settings}`
      end
      input
    end

    def Ask.for_boolean(msg)
      valid_values = ["y", "n"]
      print "%s (%s)? " % [msg, valid_values.join("/")]
      value = ""
      while value.to_s.strip.empty?
        value = $stdin.gets.to_s.strip.downcase
        if !valid_values.include?(value[0])
          puts "Please enter 'y' or 'n'"
          value = ""
        end
      end
      value.downcase[0] == "y"
    end
  end
end
