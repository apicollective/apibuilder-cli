module ApibuilderCli

  module Util

    def Util.file_join(*args)
      args.select!{|s| s.to_s.strip != "" }
      File.join(*args)
    end

    # Writes contents to a temp file, returning the path
    def Util.write_to_temp_file(contents)
      tmp = Tempfile.new('apibuilder-cli')
      Util.write_to_file(tmp.path, contents)
    end

    # Writes contents to the file at the specified path, returning the path
    def Util.write_to_file(path, contents)
      Preconditions.assert_class(path, String)
      File.open(path, "w") do |out|
        out << contents
      end
      path
    end

    # Returns the trimmed value if not empty. If empty (or nil) returns nil
    def Util.read_non_empty_string(value)
      trimmed = value.to_s.strip
      if trimmed == ""
        nil
      else
        trimmed
      end
    end

    # Returns the value only if a valid integer
    def Util.read_non_empty_integer(value)
      trimmed = Util.read_non_empty_string(value)
      if trimmed && trimmed.to_i.to_s == trimmed
        trimmed.to_i
      else
        nil
      end
    end

    # Returns first 3 characters and last 4 characters only
    def Util.mask(value)
      if value.size > 15
        letters = value.split("")
        letters[0, 3].join("") + "-XXXX-" + letters[letters.size - 4, letters.size].join("")
      else
        "XXX-XXXX-XXXX"
      end
    end

  end

  def Util.call(client, &block)
    begin
      block.call
    rescue Io::Apibuilder::Api::V0::HttpClient::ServerError => e
      puts ""
      puts "ERROR:"
      if e.message.include?("Connection refused")
        puts "  Connection refused to #{client.url}"
        puts "  Check your internet connection or otherwise connectivity"
        puts "  to API Builder."
      else
        puts "  #{e.message}"
      end
      puts ""
      exit(1)
    end
  end

end
