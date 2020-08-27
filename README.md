![Hello](https://share.adam.ac/20/QXXEtpuHaFotrkDat808.png)

Schmersion is a little library to help generate CHANGELOG documents automatically from commits that are formatted following the Conventional Commits style. There are a few conventions that you should be aware of that your repository should be following before using this:

- Commit messages should be formatted following the Conventional Commit style.
- Versions should be tagged

Schmersion will take on a couple of roles for you:

- It will automatically generate/update a CHANGELOG document (formatted as markdown, yaml, JSON, whatever you want) in your repository and commit this to your repository.
- It will suggest a new version number for your application based on the commit messages.
- It will create your version tag.

## Installation

Just install the gem:

```
gem install schmersion
```

## Getting started

The first thing you'll want to do is run `schmersion pending` in the root of your repository. This will tell you your current version (the latest version tag) and then tell you what your next version should be called and a list of valid commits that will be included in the CHANGELOG.

If you're happy with this, you can then run `schmersion release` which will take these commits, add them to your CHANGELOG files (as configured in `.schmersion.yaml`), commit them and make a tag with the given version number. You can, if you wish, override the version number at this stage.

There are other options available too:

- `schmersion install-linting` will install appropriate pre-commit hooks to your local git repository to ensure that all commit messages are appropriately written.

- `schmersion log` displays a full list of all valid commits in date order.

- `schmersion versions` displays a list of all versions in date order.

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
      # An array of sections to include with a title and an array of commit types to
      # include in that section. Sections with no commits will be excluded.
      sections:
        - title: New Features
          types: [feat]
        - title: Bug Fixes
          types: [fix]

  - name: CHANGELOG.internal.md
    formatter: markdown
    options:
      title: Katapult Internal CHANGELOG
      sections:
        - title: Public Features
          types: [feat]
          sort: alpha
        - title: Public Fixes
          types: [fix]
          sort: date
        - title: Internal Updates
          types: [chore, refactor]

  - name: CHANGELOG.yaml
    formatter: yaml
    options:
      # The commit types to include the generated YAML file.
      types: [feat, fix]
```
