# rubocop:disable Naming/FileName
# frozen_string_literal: true

command :'lint-prepare' do
  action do |context|
    require 'schmersion/repo'
    require 'schmersion/linter'
    repo = Schmersion::Repo.new(FileUtils.pwd)
    linter = Schmersion::Linter.new(repo)
    linter.prepare(context.args[0])
  end
end

# rubocop:enable Naming/FileName
