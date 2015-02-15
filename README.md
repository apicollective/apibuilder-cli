# apidoc-cli
Command line interface to apidoc

# Configuration File

The apidoc configuration file is modeled after the AWS configuration
file and hopefully is both familiar and obvious.

The file itself should be placed in ~/.apidoc-cli/config

To generate a configuration file:

bin/generate-config --organization <organization name> --token <token>

Example:

  bin/generate-config --organization gilt --token abc123

Example File:

# [default]
# organization = gilt
# 
# [organization gilt]
# token = lkjlk12j3kl21j3lk2
#
# [organization foo]
# token = bar
