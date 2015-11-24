require_relative 'lib/apidoc-cli/version'

Gem::Specification.new do |s|
  s.name              = 'apidoc-cli'
  s.homepage          = "https://github.com/mbryzek/apidoc-cli"
  s.version           = ::ApidocCli::Version.current
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Command line interface to apidoc.me"
  s.authors           = ["Michael Bryzek"]
  s.files             = %w( README.md )
  s.files             += Dir.glob("bin/**/*")
  s.files             += Dir.glob("lib/**/*")
  s.executables       = Dir.entries("bin").select {|f| !File.directory? f}
end
