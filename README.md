# apidoc-cli
Command line interface to apidoc

# Configuration File

The apidoc configuration file is modeled after the AWS configuration
file and hopefully is both familiar and obvious.

The file itself should be placed in ~/.apidoc-cli/config

To generate a configuration file:

bin/generate-config --profile <profile name> --token <token>

Example:

  bin/generate-config --profile gilt --token abc123

Example File:

# [default]
# profile = gilt
# 
# [profile gilt]
# token = abc123
#
# [profile foo]
# token = bar

To verify that your configuration file is valid:

  bin/read-config

or

  bin/read-config --path <path to config file>

