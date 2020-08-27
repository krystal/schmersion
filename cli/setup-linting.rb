# rubocop:disable Naming/FileName
# frozen_string_literal: true

command :'setup-linting' do
  desc 'Install git hooks to lint commit messages'

  option '-f', '--force', 'Override existing hooks if they exist' do |_, options|
    options[:force] = true
  end

  action do |context|
    require 'schmersion/repo'
    require 'schmersion/linter'
    repo = Schmersion::Repo.new(FileUtils.pwd)
    linter = Schmersion::Linter.new(repo)
    linter.setup(force: context.options[:force])

    puts 'Installed hooks successfully'.green
  end
end

# rubocop:enable Naming/FileName
