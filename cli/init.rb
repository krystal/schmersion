# frozen_string_literal: true

command :init do
  desc 'Create a .schmersion.yml config file'

  option '-f', '--force', 'Override existing hooks if they exist' do |_, options|
    options[:force] = true
  end

  action do |context|
    if File.exist?('.schmersion.yaml') && !context.options[:force]
      puts 'A file already exists at .schmersion.yaml'
      puts 'Use --force if you wish to re-generate it.'
      exit 1
    end

    example = <<~EXAMPLE
      # Welcome to the Schmersion config file
      #
      # This is an array of all the commit types that are supported. You can
      # override this to define your own set as needed per-project.
      #
      # types: [feat, fix, style, chore, test, refactor, perf, docs, ci, build, revert]
      #
      # By default, you can use any scope (the word in brackets following the type).
      # If you wish to restrict this, you can define a list of valid scopes.
      # scopes: [auth, api, ...]
      #
      # A key part of the configuration is how you wish to export your CHANGELOG files.w
      exports:
        - name: CHANGELOG.md
          formatter: markdown
          options:
            title: CHANGELOG
            description: This file contains all the latest changes and updates to this application.
            sections:
              - title: Features
                types: [feat]
              - title: Bug Fixes
                types: [fix]
      #
      # There are additional options you can define, check out the README for details.
      # https://github.com/krystal/schmersion
    EXAMPLE

    File.write('.schmersion.yaml', example)
    puts 'Created new .schmersion.yaml file'.green
  end
end
