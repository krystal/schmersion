# frozen_string_literal: true

require 'git'
require 'semantic'
require 'schmersion/commit_parser'
require 'schmersion/commit'
require 'schmersion/version'

module Schmersion
  class Repo

    def initialize(path)
      @repo = Git.open(path)
    end

    # Get the pending version for the currently checked out branch
    # for the repository.
    def pending_version(from: nil, to: 'HEAD', **options)
      options[:version_options] ||= {}

      if from.nil?
        from_version = versions.last
      else
        from_version = versions.find { |v, _| v.to_s == from }
        if from_version.nil?
          raise Error, "Could not find existing version named #{from}"
        end
      end

      if from_version
        previous_version, previous_version_commit = from_version
      end

      parser = CommitParser.new(@repo, previous_version_commit&.ref || :start, to)
      next_version = parser.next_version_after(previous_version, **options[:version_options])

      [
        previous_version,
        Version.new(self, next_version, parser)
      ]
    end

    def commits(start_commit, end_commit, **options)
      parser = CommitParser.new(@repo, start_commit, end_commit, **options)
      parser.commits
    end

    def current_branch
      @repo.branch.name
    end

    def versions(before: nil)
      versions = @repo.tags.each_with_object([]) do |tag, array|
        commit = @repo.gcommit(tag.sha)
        version = Semantic::Version.new(tag.name)
        array << [version, Commit.new(commit)]
      rescue ArgumentError => e
        raise unless e.message =~ /not a valid SemVer/
      end
      versions.sort_by { |_, c| c.date }
    end

  end
end
