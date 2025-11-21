require 'yaml'
require 'tempfile'

dir = File.dirname(__FILE__)
lib_dir = File.join(dir, "apibuilder-cli")

require_relative 'apibuilder-cli/preconditions'
require_relative 'apibuilder-cli/util'
require_relative 'apibuilder-cli/ask'
require_relative 'apibuilder-cli/args'
require_relative 'apibuilder-cli/config'
require_relative 'apibuilder-cli/settings'
require_relative 'apibuilder-cli/app_config'
require_relative 'apibuilder-cli/file_tracker'
require_relative 'apibuilder-cli/constants'
require_relative 'apibuilder-cli/git'
require_relative 'apibuilder-cli/version'
require_relative 'apibuilder-cli/apicollective_apibuilder_spec_v0_client'
require_relative 'apibuilder-cli/apicollective_apibuilder_common_v0_client'
require_relative 'apibuilder-cli/apicollective_apibuilder_generator_v0_client'
require_relative 'apibuilder-cli/apicollective_apibuilder_api_v0_client'

Dir.glob(File.join(lib_dir, "commands") + "/*.rb").each do |p|
  require p
end
