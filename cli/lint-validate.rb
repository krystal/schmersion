# rubocop:disable Naming/FileName
# frozen_string_literal: true

command :'lint-validate' do
  action do |context|
    require 'schmersion/repo'
    require 'schmersion/linter'
    repo = Schmersion::Repo.new(FileUtils.pwd)
    linter = Schmersion::Linter.new(repo)
    errors = linter.validate_file(context.args[0])
    if errors.empty?
      exit 0
    end

    puts
    puts '  Schmersion Commit Linting'.cyan
    puts
    puts "  Uh oh. There's a few things wrong with your commit message...".red
    puts '  Please correct these and re-commit to continue.'.red
    puts
    errors.each do |error|
      puts "  => #{error}"
    end
    puts
    exit 1
  end
end
# rubocop:enable Naming/FileName
