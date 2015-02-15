module ApidocCli

  module Util

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

end
