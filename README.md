![Hello](https://share.adam.ac/20/QXXEtpuHaFotrkDat808.png)

[![CI](https://github.com/krystal/schmersion/workflows/CI/badge.svg)](https://github.com/krystal/schmersion/actions)

Schmersion is a little library to help generate CHANGELOG documents automatically from commits with messages that are formatted following the [Conventional Commits](https://www.conventionalcommits) style (generally that means they contain a type followed by a message).

Schmersion will take on a couple of roles for you:

- It will automatically generate/update a CHANGELOG document (formatted as markdown, yaml, whatever you want) in your repository and commit this to your repository.

- It will suggest the next version number following SemVer principles.

- It will create your version tag.

## Installation

```
gem install schmersion
```

## Getting started

Start by entering the root of the repository for the app you wish to work with. Then run `schmersion init` to generate a `.schmersion.yaml` config file. Once created, open this up and configure it as appropriate with the types and export formats you want.

Next, run `schmersion pending`. This will tell you your current version (the latest version tag) and then tell you what your next version should be called and a list of valid commits that will be included in the CHANGELOG when released.

If you're happy with this, you can then run `schmersion release` which will take these commits, add them to your CHANGELOG files (as configured in `.schmersion.yaml`), commit them and make a tag with the given version number. There are a few options you can pass to the `release` method.

- `--dry-run` - run the release and just output what will happen to the terminal without actually running anything

- `-r` - override the next version number with a value of your choosing

- `--pre [type]` - specify that the next version should be a pre-release version. You can pass the prefix for this such as `beta` or `rc` and the commit will be suffixed with something like `-beta.1` as appropriate.

- `--skip-(export|commit|tag)` - you can use this to skip individual steps of the release process as needed.

## Linting

Schmersion can help make sure you write the correct commit messages too. To enable this, you need to run `schmersion setup-linting` eahc time your clone your repository. This will install some git pre-commit hooks that will validate your commit message comply with the requirements for the repository specified in the config file.

## Other commands

- `schmersion versions` - displays a list of all versions in date order.

- `schmersion log` - display all valid commits that are eligible for inclusion in version calculations and CHANGELOG exports.

- `schmersion help` - displays a list of available commands.

## Configuration

This is an example configuration file which should be placed in the root of the repository and named `.schmersion.yaml`.

```yaml
# Types is a list of the commit types that are supported. This will be enforced by the
# linter when new commits are added. Commits that are added with a type not in this list
# will always be ignored by Schmersion (along with merge commits and commits which do not
# match the required format).
types:
  - feat
  - fix
  - chore
  - refactor

# If you wish to limit which scopes are valid, you can list them here. They apply to
# all types. Do not specify this if you wish to allow any scope.
scopes:
  - rspec
  - login

# These options allow you to configure the rules used for linting commit messages.
linting:
  max_description_length: 100

# These options allow you to customise how the next version is determined.
version_options:
  # By default, any breaking change will cause an increase to the MAJOR part of
  # of the version. You can disable this if you wish by setting this option to true.
  breaking_change_not_major: false

# Finally, you can define options for how you wish your CHANGELOG files to be
# exported when releases happen. You can define the name (path) where the file
# will be exported to as well as the formatter and any options which the formatter
# may wish to use. You can define as many exports as you wish.
exports:
  - name: CHANGELOG.md
    formatter: markdown
    options:
      # The title to add at the top of the file
      title: Katapult CHANGELOG
      # Some additional descriptive text
      description: Some example text which will be inserted at the top of the CHANGELOG.
      # URLs are used in some generated markdown files to link to various things.
      # By default, these are determined from the repository URL but you can override
      # these below if you wish.
      urls:
        commit: https://customdomain.com/$REF
      # An array of sections to include with a title and an array of commit types to
      # include in that section. Sections with no commits will be excluded.
      sections:
        - title: New Features
          types: [feat]
        - title: Bug Fixes
          types: [fix]

  - name: CHANGELOG.yaml
    formatter: yaml
    options:
      # The commit types to include the generated YAML file.
      types: [feat, fix]
```
