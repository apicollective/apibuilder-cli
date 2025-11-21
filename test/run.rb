#!/usr/bin/env ruby

# Ensure we're in a valid directory before running tests
test_dir = File.dirname(__FILE__)
Dir.chdir(test_dir) unless Dir.pwd == test_dir

require_relative '../src/apibuilder-cli'

def run(command)
  puts command
  system(command)
end

gem_home = File.join(File.dirname(__FILE__), '../gems').sub(/^\.\//, '')
rspec = File.join(gem_home, 'bin/rspec')
if !File.exist?(rspec)
  run("export GEM_HOME=%s && gem install rspec --version 3.13.0 --install-dir %s" % [gem_home, gem_home])
end

files = `find spec -type f -name "*spec.rb"`.strip.split

result = output = nil

tmp = "/tmp/apibuilder-cli.tmp"
result = run("export GEM_HOME=%s && %s %s > %s" % [gem_home, rspec, files.join(" "), tmp])
output = IO.read(tmp)
puts output

if result
  exit(0)
else
  puts ""
  puts "To rerun particular scripts, use rspec at:"
  puts "export GEM_HOME=%s && %s" % [gem_home, rspec]
  exit(1)
end
