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

    #
    # Converts generator attributes from various formats to the standard
    # array of Attribute objects expected by the API.
    #
    # @param attributes [Hash, Array, nil] The attributes in either legacy hash format
    #   or new array format
    # @return [Array<Io::Apibuilder::Generator::V0::Models::Attribute>] Array of
    #   properly formatted Attribute objects
    #
    # Supports three input formats:
    #
    # 1. Legacy hash format:
    #    { "key1" => "value1", "key2" => "value2" }
    #
    # 2. Array of hashes with name/value:
    #    [{ "name" => "key1", "value" => "value1" }]
    #
    # 3. Array of hashes with name/value where value is an object:
    #    [{ "name" => "filter", "value" => { "operations" => [...] } }]
    #
    def Util.normalize_generator_attributes(attributes)
      return [] if attributes.nil? || (attributes.respond_to?(:empty?) && attributes.empty?)

      require 'json'

      if attributes.is_a?(Array)
        # Handle array format
        attributes.map do |attr|
          if defined?(Io::Apibuilder::Generator::V0::Models::Attribute) &&
             attr.is_a?(Io::Apibuilder::Generator::V0::Models::Attribute)
            # Already the correct type
            attr
          elsif attr.is_a?(Hash) && attr['name']
            # Convert hash to Attribute object
            name = attr['name']
            value = attr['value']

            # Convert non-string values to JSON
            value_str = case value
                        when String
                          value
                        when nil
                          ""
                        else
                          value.to_json
                        end

            Io::Apibuilder::Generator::V0::Models::Attribute.new(
              :name => name,
              :value => value_str
            )
          else
            raise "Invalid attribute format: expected hash with 'name' and 'value' keys, got: #{attr.inspect}"
          end
        end
      elsif attributes.is_a?(Hash)
        # Legacy format: convert hash to array of Attribute objects
        attributes.map do |name, value|
          # Ensure value is a string
          value_str = value.is_a?(String) ? value : value.to_json

          Io::Apibuilder::Generator::V0::Models::Attribute.new(
            :name => name,
            :value => value_str
          )
        end
      else
        raise "Invalid attributes format: expected Hash or Array, got: #{attributes.class}"
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
