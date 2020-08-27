# frozen_string_literal: true

command :release do
  desc 'Create a release'

  option '-r [VERSION]', 'Override the version number' do |value, options|
    options[:version] = value
  end

  option '--dry-run', "Don't actually do anything, just show a preview" do |value, options|
    options[:dry_run] = true
  end

  action do |context|
    require 'schmersion/repo'
    require 'schmersion/releaser'
    repo = Schmersion::Repo.new(FileUtils.pwd)
    releaser = Schmersion::Releaser.new(repo, context.options)
    releaser.release
  end
end
