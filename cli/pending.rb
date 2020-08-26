# frozen_string_literal: true

command :pending do
  desc 'Displays commits pending'

  option '--from [REF]', 'Version to start from (default: latest version)' do |value, options|
    options[:from] = value
  end

  option '--to [REF]', 'Commit to end at (default: HEAD)' do |value, options|
    options[:to] = value
  end

  action do |context|
    require 'schmersion/repo'
    require 'schmersion/helpers'

    repo = Schmersion::Repo.new(FileUtils.pwd)
    current_version, next_version = repo.pending_version(
      from: context.options[:from],
      to: context.options[:to],
      version_options: {
        # breaking_change_not_major: true
      }
    )

    puts
    if current_version
      puts 'The current published version is:'
      puts
      puts "    #{current_version.to_s.cyan}"
      puts
      puts 'The next version will be:'
    else
      puts 'The first version will be:'
    end
    puts
    puts "    #{next_version.version.to_s.green}"
    puts
    puts 'The following commits will be included:'
    puts
    Schmersion::Helpers.print_commit_list(next_version.commits, prefix: '    ')
    puts
  end
end
