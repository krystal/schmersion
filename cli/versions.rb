# frozen_string_literal: true

command :versions do
  desc 'Print a list of all versions in version order'
  action do |context|
    require 'schmersion/repo'
    require 'colorize'

    repo = Schmersion::Repo.new(FileUtils.pwd)
    repo.versions.each do |version, _|
      puts version
    end
  end
end
