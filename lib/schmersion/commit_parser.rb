# frozen_string_literal: true

require 'schmersion/commit'

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
      if current_version.nil?
        current_version = Semantic::Version.new('1.0.0')
        new_version = current_version
      elsif commits.any? { |c| c.message.breaking_change? } && !options[:breaking_change_not_major]
        new_version = current_version.increment!(:major)
      elsif commits.any? { |c| c.message.type == 'feat' }
        new_version = current_version.increment!(:minor)
      else
        new_version = current_version.increment!(:patch)
      end

      if options[:pre]
        add_pre_to_version(options[:pre], new_version, current_version)
      end

      new_version
    end

    def skip_commit?(commit)
      # We never want to see merge commits...
      return true if commit.raw_commit.parents.size > 1
      return true unless commit.message.valid?

      false
    end

    private

    def add_pre_to_version(prefix, version, current_version)
      prefix = 'pre' unless prefix.is_a?(String)

      current_prefix, current_sequence = current_version&.pre&.split('.', 2)
      if current_prefix == prefix
        # If the current version's prefix is the same as the one
        # that's been selected, we'll increment its integer
        pre_sequence = current_sequence.to_i + 1
      else
        pre_sequence = 1
      end
      version.pre = "#{prefix}.#{pre_sequence}"
      version
    end

  end
end
