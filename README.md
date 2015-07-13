# apidoc-cli
Command line interface to apidoc

# Setup for public APIs

No setup needed - just use the apidoc command directly (see below)

# Setup for private APIs

1. [Create a token](http://www.apidoc.me/tokens/) for your user account

2. Create a configuration file in ~/.apidoc/config
   Example File:

        [default]
        token = <your API token>

3. Verify that your configuration file is valid:

        bin/read-config

# Commands

## list

List all organizations that you have access to:

    bin/apidoc list organizations

List all applications that belong to a specific organization:

    bin/apidoc list applications <organization key>

List all versions of a particular application

    bin/apidoc list versions <organization key> <application key>
    
Note since the GET requests in apidoc are paginated, you might need to
paginate. Where pagination is required, we use two environment
variables: LIMIT, OFFSET

    LIMIT=10 OFFSET=10 bin/apidoc list organizations
    
## code

Invoke a code generator from the command line

    bin/apidoc <organization key> <application key> <version> <generator> [<filename>]
    
For example, to generate a play 2.3 client for the latest version of apidoc itself:

    bin/apidoc code bryzek apidoc-api latest play_2_3_client

Each code generator returns a list of files. To download a specific file:

    bin/apidoc code bryzek apidoc-api latest play_2_3_client <filename>
    
For example:

    bin/apidoc code bryzek apidoc-api latest play_2_3_client BryzekApidocApiClient.scala

To view a list of available generators visit [apidoc.me/generators](http://www.apidoc.me/generators)

## update

Invoke code generator based on configuration from a yaml configuration file

    bin/apidoc update [--path path]
    
        path defaults to .apidoc in the current directory.

The configuration file is a YAML file that follows the convention:

    command:
      org:
        project:
          version: <version>
          generators:
            <generator name 1>: <path to directory or specific filename>
            <generator name 2>: <path to directory or specific filename>
            <generator name 3>: <path to directory or specific filename>

Example File:

    code:
      bryzek:
        apidoc:
          version: latest
          generators:
            play_2_3_client: generated/app
            play_2_x_routes: api/conf/routes
        apidoc-spec:
          version: latest
          generators:
            play_2_3_client: generated/app
        apidoc-generator:
          version: latest
          generators:
            play_2_3_client: generated/app
    
## cli itself

Display the current version of the CLI.

    bin/apidoc cli version

Display the latest available version of the CLI.

    bin/apidoc cli latest

Upgrade to the latest version

    bin/apidoc cli upgrade

# Environment Variables

    PROFILE: Select a specific profile to use, read from the .apidoc
             configuration file
