# frozen_string_literal: true

command :log do
  desc 'Print all commits in a range nicely'

  option '--from [REF]', 'Commit to start from (default: beginning of time)' do |value, options|
    options[:from] = value
  end

  option '--to [REF]', 'Commit to finish with (default: current branch)' do |value, options|
    options[:to] = value
  end

  action do |context|
    require 'schmersion/repo'
    require 'schmersion/helpers'
    require 'colorize'

    repo = Schmersion::Repo.new(FileUtils.pwd)

    from = context.options[:from] || :start
    to = context.options[:to] || repo.current_branch

    commits = repo.commits(from, to, exclude_with_invalid_messages: true)

    Schmersion::Helpers.print_commit_list(commits)
  end
end
