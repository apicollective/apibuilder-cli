#!/usr/bin/env ruby
#
# This scripts creates the actual release of apibuilder-cli
#  - updates src/apibuilder-cli/version.rb
#  - creates git tags
#
# == Usage
#  ./util/create-release.rb
#

load File.join(File.dirname(__FILE__), '../src/apibuilder-cli.rb')

dirty_files = `git status --porcelain`.strip
#ApibuilderCli::Preconditions.check_state(dirty_files == "", "Local checkout is dirty:\n%s" % dirty_files)

version = ApibuilderCli::Version.current
puts "Current version is %s" % version

pieces = version.split(/\./)
new_version = [pieces[0], pieces[1], pieces[2].to_i + 1].join(".")

print "New version [#{new_version}]: "
answer = $stdin.gets.strip
if answer != ""
  new_version = answer
end

def replace_version(file, new_version)
  new_contents = ""
  found = false
  IO.readlines(file).each do |l|
    if l.match(/\d+\.\d+\.\d+/)
      found = true
      l.sub!(/\d+\.\d+\.\d+/, new_version)
    end
    new_contents << l
  end
  ApibuilderCli::Preconditions.check_state(found, "Failed to update version in #{file}")
  File.open(file, "w") { |out| out << new_contents }
  puts "Updated version number in #{file}"
  file
end

files = []
files << replace_version("src/apibuilder-cli/version.rb", new_version)
files << replace_version("DEVELOPER.md", new_version)

def system_or_error(cmd)
  if !system(cmd)
    raise "Error running command: #{cmd}"
  end
end

if new_version == version
  puts "Version has not changed. Exiting"
  exit(1)
end

system_or_error("git commit -m 'autocommit: Update version to %s' #{files.join(" ")}" % new_version)

puts "Creating git tag[%s]" % new_version
system_or_error("git tag -a -m '%s' %s" % [new_version, new_version])

puts "Release tag[%s] created" % new_version

commands = []
commands << "git push origin"
commands << "git push --tags origin"

puts ""
if ApibuilderCli::Ask.for_boolean("Push to git?")
  commands.each do |cmd|
    puts " ==> #{cmd}"
    system_or_error(cmd)
  end

  puts ""
  if ApibuilderCli::Ask.for_boolean("Bump brew formula?")
    system_or_error("brew bump-formula-pr apibuilder-cli --version #{new_version}")
  end

else
  puts "To complete the release:"
  commands.each do |cmd|
    puts "  #{cmd}"
  end
end
