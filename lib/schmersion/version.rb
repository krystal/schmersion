# frozen_string_literal: true

module Schmersion
  class Version

    attr_reader :version
    attr_reader :commit_parser

    def initialize(repo, version, commit_parser)
      @repo = repo
      @version = version
      @commit_parser = commit_parser
    end

    def commits
      @commit_parser.commits
    end

    def start_commit
      @commit_parser.start_commit
    end

    def end_commit
      @commit_parser.end_commit
    end

  end
end
