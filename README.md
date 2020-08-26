# Schmersion

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
