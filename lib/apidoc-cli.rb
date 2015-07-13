require 'yaml'
require 'tempfile'

dir = File.dirname(__FILE__)
lib_dir = File.join(dir, "apidoc-cli")

load File.join(lib_dir, 'preconditions.rb')
load File.join(lib_dir, 'util.rb')
load File.join(lib_dir, 'args.rb')
load File.join(lib_dir, 'config.rb')
load File.join(lib_dir, 'app_config.rb')
load File.join(lib_dir, 'version.rb')
load File.join(lib_dir, 'bryzek_apidoc_spec_client.rb')
load File.join(lib_dir, 'bryzek_apidoc_generator_client.rb')
load File.join(lib_dir, 'bryzek_apidoc_api_client.rb')
