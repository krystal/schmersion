# frozen_string_literal: true

require 'schmersion/formatters'

module Schmersion
  class Releaser

    COLORS = [:blue, :red, :yellow, :magenta, :green, :cyan].freeze

    def initialize(repo, **options)
      @repo = repo
      @options = options
      @exports = {}
    end

    def release
      check_for_for_existing_version
      generate_exports
      preview_exports
      save_exports
      commit
      tag
      display_prompt
    end

    private

    def check_for_for_existing_version
      if @repo.version?(version.version)
        raise Error, "#{version.version} already exists in this repository"
      end

      true
    end

    def generate_exports
      return if skip?(:export)

      @exports = {}
      @repo.config.exports.each do |formatter|
        output = formatter.generate(@repo, version)
        @exports[formatter] = output
      end
      @exports
    end

    def preview_exports
      return if skip?(:export)
      return unless dry_run?

      @exports.each_with_index do |(formatter, output), index|
        color = COLORS[index % COLORS.size]
        puts formatter.filename.colorize(color: :white, background: color)
        output.split("\n").each do |line|
          print '> '.colorize(color: color)
          puts line
        end
      end
    end

    def save_exports
      return if skip?(:export)

      @exports.each do |formatter, output|
        action 'save', formatter.filename do
          formatter.insert(output)
        end
      end
    end

    def commit
      return if skip?(:commit)

      action 'commit', version.commit_message do
        @repo.repo.reset
        @exports.each_key do |formatter|
          @repo.repo.add(formatter.filename)
        end
        @repo.repo.commit(version.commit_message, allow_empty: true)
      end
    end

    def tag
      return if skip?(:tag)

      action 'tag', version.version.to_s do
        @repo.repo.add_tag(version.version.to_s)
      end
    end

    def display_prompt
      puts
      puts "Release of #{version.version} completed".white.on_green

      return if skip?(:tag) && skip?(:commit)

      print 'Now run '
      print "git push --tags origin #{@repo.current_branch}".cyan
      puts ' to publish'
    end

    def version
      @version ||= begin
        @repo.pending_version(
          override_version: @options[:version],
          version_options: {
            pre: @options[:pre],
            breaking_change_not_major: @repo.config.version_options['breaking_change_not_major']
          }
        )[1]
      end
    end

    def dry_run?
      @options[:dry_run] == true
    end

    def action_color
      dry_run? ? :magenta : :green
    end

    def action(action, text)
      yield unless dry_run?
      print "#{action}: ".colorize(action_color)
      puts text
    end

    def skip?(type)
      return false if @options[:skips].nil?

      @options[:skips].include?(type)
    end

  end
end
