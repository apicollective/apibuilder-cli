#!/usr/bin/env ruby
#
# This scripts creates the actual release of apidoc-clischema-evolution-manager
#  - updates lib/apidoc-cli/version.rb
#  - creates git tags
#
# == Usage
#  ./util/create-release.rb
#

load File.join(File.dirname(__FILE__), '../lib/apidoc-cli.rb')

dirty_files = `git status --porcelain`.strip
ApidocCli::Preconditions.check_state(dirty_files == "", "Local checkout is dirty:\n%s" % dirty_files)

version = ApidocCli::Version.current
puts "Current version is %s" % version

pieces = version.split(/\./)
new_version = [pieces[0], pieces[1], pieces[2].to_i + 1].join(".")

print "New version [#{new_version}]: "
answer = $stdin.gets.strip
if answer != ""
  new_version = answer
end

if new_version == version
  puts "Version has not changed. Exiting"
  exit(1)
end

version_path = "lib/apidoc-cli/version.rb"
new_contents = ""
found = false
IO.readlines(version_path).each do |l|
  if l.match(/VERSION\s*=\s*'\d+\.\d+\.\d+'/)
    found = true
    l.sub!(/VERSION = '\d+\.\d+\.\d+'.*$/, "VERSION = '%s' # Automatically updated by util/create-release.rb" % new_version)
  end
  new_contents << l
end
ApidocCli::Preconditions.check_state(found, "Failed to update #{version_path}")

puts "Update version in #{version_path}"
File.open(version_path, "w") { |out| out << new_contents }

def system_or_error(cmd)
  if !cmd
    raise "Error running command: #{cmd}"
  end
end

system_or_error("git commit -m 'autocommit: Update version to %s' %s" % version_path)

puts "Creating git tag[%s]" % new_version
system_or_error("git tag -a -m '%s' %s" % [new_version, new_version])

puts "Release tag[%s] created. Need to:" % new_version
puts "  git push origin"
puts "  git push --tags origin"
