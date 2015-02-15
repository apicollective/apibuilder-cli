#!/usr/bin/env ruby

module ApidocCli

  module Constants

    APIDOC_API_URI = (ENV['APIDOC_API_URI'] || "http://api.apidoc.me") if !defined?(APIDOC_API_URI)

  end

end
