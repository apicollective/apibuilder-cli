# apidoc-cli
Command line interface to apidoc

# Configuration File

The apidoc configuration file is modeled after the AWS configuration
file and hopefully is both familiar and obvious.

The file itself should be placed in ~/.apidoc-cli/config

If you are accessing non public applications in apidoc, you will first need to create [an API token](http://www.apidoc.me/tokens/).

To generate a configuration file:

    bin/generate-config --profile <profile name> --token <token>

Example:

    bin/generate-config --profile gilt --token abc123

Example File:

    [default]
    profile = gilt

    [profile gilt]
    token = abc123

    [profile foo]
    token = bar

To verify that your configuration file is valid:

    bin/read-config

or

    bin/read-config --path <path to config file>

# Commands

## list

List all organizations that you have access to:

    bin/apidoc-cli list organizations

List all applications that belong to a specific organization:

    bin/apidoc-cli list applications <organization key>
    
Note since the GET requests in apidoc are all paginated, you might need to paginate. Where pagination is required, we use two environment variables: LIMIT, OFFSET

    LIMIT=10 OFFSET=10 bin/apidoc-cli list organizations
    
## code

Invoke a code generator from the command line

    bin/apidoc-cli <organization key> <application key> <version> <generator>
    
For example, to generate a play 2.3 client for the latest version of apidoc itself:

    bin/apidoc-cli code gilt apidoc latest play_2_3_client
    
To view a list of available generators visit [apidoc.me/generators](http://www.apidoc.me/generators)


    
