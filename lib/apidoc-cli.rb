require 'yaml'

dir = File.dirname(__FILE__)
lib_dir = File.join(dir, "apidoc-cli")

load File.join(lib_dir, 'constants.rb')
load File.join(lib_dir, 'preconditions.rb')
load File.join(lib_dir, 'util.rb')
load File.join(lib_dir, 'args.rb')
load File.join(lib_dir, 'config.rb')
load File.join(lib_dir, 'app_config.rb')
load File.join(lib_dir, 'com_gilt_apidoc_v0_client.rb')
