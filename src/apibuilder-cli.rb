require 'yaml'
require 'tempfile'

dir = File.dirname(__FILE__)
lib_dir = File.join(dir, "apibuilder-cli")

load File.join(lib_dir, 'preconditions.rb')
load File.join(lib_dir, 'util.rb')
load File.join(lib_dir, 'args.rb')
load File.join(lib_dir, 'config.rb')
load File.join(lib_dir, 'settings.rb')
load File.join(lib_dir, 'app_config.rb')
load File.join(lib_dir, 'file_tracker.rb')
load File.join(lib_dir, 'git.rb')
load File.join(lib_dir, 'version.rb')
load File.join(lib_dir, 'apicollective_apibuilder_spec_v0_client.rb')
load File.join(lib_dir, 'apicollective_apibuilder_common_v0_client.rb')
load File.join(lib_dir, 'apicollective_apibuilder_generator_v0_client.rb')
load File.join(lib_dir, 'apicollective_apibuilder_api_v0_client.rb')

Dir.glob(File.join(lib_dir, "commands") + "/*.rb").each do |p|
  load p
end
