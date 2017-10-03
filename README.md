# apibuilder-cli
Command line interface to API Builder

# Setup for public APIs

No setup needed - just use the API Builder command directly (see below)

# Setup for private APIs

1. [Create a token](http://www.apibuilder.io/tokens/) for your user account

2. Create a configuration file in ~/.apibuilder/config
   Example File:

        [default]
        token = <your API token>

3. Verify that your configuration file is valid:

        bin/read-config

# Commands

## list

List all organizations that you have access to:

    bin/apibuilder list organizations

List all applications that belong to a specific organization:

    bin/apibuilder list applications <organization key>

List all versions of a particular application

    bin/apibuilder list versions <organization key> <application key>
    
Note since the GET requests in API Builder are paginated, you might need to
paginate. Where pagination is required, we use two environment
variables: LIMIT, OFFSET

    LIMIT=10 OFFSET=10 bin/apibuilder list organizations
    
## code

Invoke a code generator from the command line

    bin/apibuilder <organization key> <application key> <version> <generator> <target dir> [<filename> ...]
    
For example, to generate a play 2.3 client for the latest version of apibuilder itself:

    bin/apibuilder code apicollective apibuilder-api latest play_2_5_client .

Each code generator returns a list of files. To download a specific file:

    bin/apibuilder code apicollective apibuilder-api latest play_2_5_client . [<filename> ...]
    
For example:

    bin/apibuilder code apicollective apibuilder-api latest http4s_0_17 . ApicollectiveApibuilderApiV0Client.scala ApicollectiveApibuilderApiV0Server.scala
    
The file names support wildcard expansion (`?` for a single character, `*` for zero or more), e.g:

    bin/apibuilder code apicollective apibuilder-api latest http4s_0_17 . *ApiV?Client*.scala

To view a list of available generators visit [apibuilder.io/generators](http://www.apibuilder.io/generators)

## update

Invoke code generator based on configuration from a yaml configuration file

    bin/apibuilder update [--path path]
    
        path defaults to .apibuilder in the current directory.

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
      apicollective:
        apibuilder:
          version: latest
          generators:
            play_2_5_client: generated/app
            play_2_x_routes: api/conf/routes
        apibuilder-spec:
          version: latest
          generators:
            play_2_5_client: generated/app
        apibuilder-generator:
          version: latest
          generators:
            play_2_5_client: generated/app

In addition, you can specify global settings for how the client behaves:

Example File w/ Settings:

    settings:
      code.create.directories: true

    code:
      apicollective:
        apibuilder:
          version: latest
          generators:
            play_2_5_client: generated/app

Supported settings include:

  - code.create.directories: Defaults to false. If true, when you run
    `apibuilder update`, we will create the subdirectories as specified by
    the code generator.


## cli itself

Display the current version of the CLI.

    bin/apibuilder cli version

Display the latest available version of the CLI.

    bin/apibuilder cli latest

Upgrade to the latest version

    bin/apibuilder cli upgrade

# Environment Variables

    PROFILE: Select a specific profile to use, read from the .apibuilder
             configuration file

    APIBUILDER_TOKEN: If specified, this is the apibuilder token we use

To setup a configuration profile, add a section to ~/.apibuilder/config for each profile:

```
[default]
token = xxx

[profile localhost]
api_uri = http://localhost:9001
token = yyy
```