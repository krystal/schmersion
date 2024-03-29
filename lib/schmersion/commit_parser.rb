# frozen_string_literal: true

require 'schmersion/commit'
require 'schmersion/version_calculator'

module Schmersion
  class CommitParser

    MAX_COMMITS = 100_000_000

    attr_reader :commits

    def initialize(repo, start_commit, end_commit, **options)
      @start_commit = start_commit
      @end_commit = end_commit
      @options = options

      @commits = []

      if @start_commit == :start
        # If start is provided, use the first commit as the initial reference.
        # Ideally this would actually start from the beginning of time and include
        # this commit.
        first_commit = repo.log(MAX_COMMITS).last
        @start_commit = first_commit.sha
      end

      @raw_commits = repo.log(MAX_COMMITS).between(@start_commit, @end_commit)

      parse
    end

    def parse
      @commits = []
      @raw_commits.each do |commit|
        commit = Commit.new(commit)

        next if skip_commit?(commit)

        @commits << commit
      end
      @commits = @commits.reverse
      @commits
    end

    def next_version_after(current_version, **options)
      calculator = VersionCalculator.new(current_version, commits, **options)
      calculator.calculate
    end

    def skip_commit?(commit)
      # We never want to see merge commits...
      return true if commit.raw_commit.parents.size > 1
      return true unless commit.message.valid?

      false
    end

  end
end
