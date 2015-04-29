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

    bin/apidoc <organization key> <application key> <version> <generator>
    
For example, to generate a play 2.3 client for the latest version of apidoc itself:

    bin/apidoc code gilt apidoc latest play_2_3_client
    
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
            <generator name 1>: <path>
            <generator name 2>: <path>
            <generator name 3>: <path>

Example File:

    code:
      gilt:
        apidoc:
          version: latest
          generators:
            play_2_3_client: generated/app/ApidocClient.scala
            play_2_x_routes: api/conf/routes
        apidoc-spec:
          version: latest
          generators:
            play_2_3_client: generated/app/ApidocSpec.scala
        apidoc-generator:
          version: latest
          generators:
            play_2_3_client: generated/app/ApidocGenerator.scala
    
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
