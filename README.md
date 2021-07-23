# apibuilder-cli
Command line interface to API Builder

# Install

On MacOS using [brew](https://formulae.brew.sh/formula/apibuilder-cli):
```
brew install apibuilder-cli
```

For other platforms:
```
sudo ./install.sh /usr/local
```

# Setup for public APIs

No setup needed - just use the API Builder command directly (see below)

# Setup for private APIs

Run ```bin/create-config``` and follow the instructions. This will walk you through the following steps:

1. [Create a token](https://app.apibuilder.io/tokens/) for your user account

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

    bin/apibuilder code <organization key> <application key> <version> <generator> <target dir> [<filename> ...]
    
For example, to generate a play 2.6 client for the latest version of apibuilder itself:

    bin/apibuilder code apicollective apibuilder-api latest play_2_6_client .

Each code generator returns a list of files. To download a specific file:

    bin/apibuilder code apicollective apibuilder-api latest play_2_6_client . [<filename> ...]
    
For example:

    bin/apibuilder code apicollective apibuilder-api latest http4s_0_17 . ApicollectiveApibuilderApiV0Client.scala ApicollectiveApibuilderApiV0Server.scala
    
The file names support wildcard expansion (`?` for a single character, `*` for zero or more), e.g:

    bin/apibuilder code apicollective apibuilder-api latest http4s_0_17 . *ApiV?Client*.scala

To view a list of available generators visit [apibuilder.io/generators](https://app.apibuilder.io/generators)

## upload

Upload a new version of an api given the json descriptor.

```
bin/apibuilder upload <organization key> <application key> <file> --version <version> [--force] [--silent] [--update-config <optional path>]
```

For example:

```
bin/apibuilder upload apicollective apibuilder-api apibuilder-api/api.json --version 1.0.1
```

The `--force` flag will allow you to re-upload an api.json even if there are no changes since the previously uploaded version.

When using the `--silent` flag, the suggested tag will be automatically used. This is useful for automated uploading via git hooks and/or CD pipelines.

The `--update-config` flag tells the cli to update the local `.apibuilder/config` with the new version of the given api. It uses either the default path or the path given in the argument.

## update

Invoke code generator based on configuration stored in a local file:

    bin/apibuilder update [--path path] [--org org-name] [--app project-name]
    
        path defaults to `.apibuilder/config` in the current directory. Note that this file
        should contain only the parameters needed to identify which code generators to
        invoke and is independent from the global `~/.apibuilder/config` file where you
        store your token.

        Specifying `--org` will limit the update to only projects within that org;
        all code generated from other orgs will remain untouched. Can be combined with
        `--app` but not required.

        Specifying `--app` will limit the update to only projects that match the given name;
        all code generated from other projects will remain untouched. Can be combined with
        `--org` but not required.

The configuration file is a YAML file that follows the convention:

    command:
      org:
        project:
          version: <version>
          generators:
            <generator name 1>:
              target: <path to directory or specific filename>
            <generator name 2>:
              target: <path to directory or specific filename>
              files: <file name or file pattern>
            <generator name 3>:
              target: <path to directory or specific filename>
              files:
                - <file name or file pattern>
                - <file name or file pattern>

Example File:

    code:
      apicollective:
        apibuilder:
          version: latest
          generators:
            play_2_6_client:
              target: generated/app
            play_2_x_routes:
              target: api/conf/routes
              files: apicollective*.*
        apibuilder-spec:
          version: latest
          generators:
            play_2_6_client:
              target: generated/app
              files:
                - apicollective*.*
                - '*client.rb'
        apibuilder-generator:
          version: latest
          generators:
            play_2_6_client: generated/app

Note: Previously the configuration file syntax did not specify any files and instead specified the path as the value of the generator name.
While still supported, this syntax is deprecated:

    command:
      org:
        project:
          version: <version>
          generators:
            <generator name>: <path to directory or specific filename>

If the same generator needs to be invoked multiple times for different target directories, the YAML file can have the following alternate syntax:

    command:
      org:
        project:
          version: <version>
          generators:
            - generator: <generator name>:
              target: <path 1>
              files:
                - <file name or file pattern>
            - generator: <generator name>:
              target: <path 2>
              files:
                - <file name or file pattern>

In addition, you can specify global settings for how the client behaves:

Example File w/ Settings:

    settings:
      code.create.directories: true

    code:
      apicollective:
        apibuilder:
          version: latest
          generators:
            play_2_6_client: generated/app

Supported settings include:

  - code.create.directories: Defaults to false. If true, when you run
    `apibuilder update`, we will create the subdirectories as specified by
    the code generator.

You can also specify attributes to pass in to the code generators
(both global and local), including the use of a wildcard to select
multiple generators to which to apply the attributes:

Example File w/ Global Generator Attributes:

    attributes:
      generators:
        foo*:
          key: value
        play_2_6_client:
          foo: bar

    code:
      apicollective:
        apibuilder:
          version: latest
          generators:
            play_2_6_client: generated/app

Example File w/ Local Generator Attributes:

    code:
      happycorp:
        api-salary-calculator:
            version: 1.3.5
            generators:
              - generator: play_2_6_client
                target: src/test/generated
                attributes:
                  foo: baz
                files:
                  - HappycorpApiSalaryCalculatorV0MockClient.scala

Supported attributes are defined by each code generators.


## clean

Delete versions in ApiBuilder that are not tagged in the source repo.

```
bin/apibuilder clean <organization key> <application key> [--branch <branch name>] [--silent] [--legacy]
```

For example:

```
bin/apibuilder clean apicollective apibuilder-api --branch dev
```

When using the `--silent` flag, the suggested versions will be automatically deleted without prompting. This is useful for automated cleanup via git hooks and/or CD pipelines.

If you have versions that use the legacy default naming (i.e. that match the pattern `/^.*-\d+-g[0-9a-f]{7}$/`) and belong on a non-master branch, use the `--legacy` flag to interactively move those versions to the proper branch. You only need to run this once, at the point of migrating from the legacy naming to the branch naming. Afterwards, simply run `clean` without the `--legacy` flag.

## cli itself

Display the current version of the CLI.

    bin/apibuilder cli version

Display the latest available version of the CLI.

    bin/apibuilder cli latest

Upgrade to the latest version

    bin/apibuilder cli upgrade

# Environment Variables

    PROFILE: Select a specific profile to use, read from the .apibuilder/config
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
