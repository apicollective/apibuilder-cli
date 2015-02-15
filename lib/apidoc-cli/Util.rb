module ApidocCli

  module Util

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
