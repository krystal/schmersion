# frozen_string_literal: true

command :release do
  desc 'Create a release'

  option '-r [VERSION]', 'Override the version number' do |value, options|
    options[:version] = value
  end

  option '--dry-run', "Don't actually do anything, just show a preview" do |_, options|
    options[:dry_run] = true
  end

  option '--pre [PREFIX]', 'Create a pre-release version' do |value, options|
    options[:pre] = value || true
  end

  option '--skip-export', "Don't generate new CHANGELOG exports" do |_, options|
    options[:skips] ||= []
    options[:skips] << :export
  end

  option '--skip-commit', "Don't commit anything" do |_, options|
    options[:skips] ||= []
    options[:skips] << :commit
  end

  option '--skip-tag', "Don't create a tag" do |_, options|
    options[:skips] ||= []
    options[:skips] << :tag
  end

  action do |context|
    require 'schmersion/repo'
    require 'schmersion/releaser'
    repo = Schmersion::Repo.new(FileUtils.pwd)
    releaser = Schmersion::Releaser.new(repo, **context.options)
    releaser.release
  end
end
