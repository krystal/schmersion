# frozen_string_literal: true

require 'yaml'
require 'git'
require 'semantic'
require 'schmersion/commit_parser'
require 'schmersion/commit'
require 'schmersion/version'
require 'schmersion/config'

module Schmersion
  class Repo

    attr_reader :path
    attr_reader :repo

    def initialize(path)
      @path = path
      @repo = Git.open(path)
    end

    def config
      load_config(['.schmersion.yaml', '.schmersion.yml'])
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
      if v = options[:override_version]
        begin
          next_version = Semantic::Version.new(v)
        rescue ArgumentError => e
          if e.message =~ /not a valid SemVer/
            raise Error, "'#{v}' is not a valid version"
          end

          raise
        end
      else
        next_version = parser.next_version_after(previous_version, **options[:version_options])
      end

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

    def version?(version)
      @repo.tag(version.to_s).is_a?(Git::Object::Tag)
    rescue Git::GitTagNameDoesNotExist
      false
    end

    def versions
      versions = @repo.tags.each_with_object([]) do |tag, array|
        commit = @repo.gcommit(tag.sha)
        version = Semantic::Version.new(tag.name)
        array << [version, Commit.new(commit)]
      rescue ArgumentError => e
        raise unless e.message =~ /not a valid SemVer/
      end
      versions.sort_by { |_, c| c.date }
    end

    private

    def load_config(filenames)
      filenames.each do |filename|
        path = File.join(@path, filename)
        if File.file?(path)
          return Config.new(::YAML.load_file(path))
        end
      end

      Config.new({})
    end

  end
end
