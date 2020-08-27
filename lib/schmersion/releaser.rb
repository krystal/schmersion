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
      generate_exports
      preview_exports
      save_exports
      commit
      tag
    end

    private

    def generate_exports
      @exports = {}
      @repo.config.exports.each_with_index do |formatter, index|
        output = formatter.generate(version)
        @exports[formatter] = output
      end
      @exports
    end

    def preview_exports
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
      @exports.each do |formatter, output|
        action 'save', formatter.filename do
          formatter.insert(output)
        end
      end
    end

    def commit
      action 'commit', version.commit_message do
        @repo.repo.reset
        @exports.each_key do |formatter|
          @repo.repo.add(formatter.filename)
        end
        @repo.repo.commit(version.commit_message)
      end
    end

    def tag
      action 'tag', version.version.to_s do
        @repo.repo.add_tag(version.version.to_s)
      end
    end

    def version
      @next_version ||= begin
        @repo.pending_version(
          override_version: @options[:version]
        )[1]
      end
    end

    def dry_run?
      @options[:dry_run] == true
    end

    def action_color
      dry_run? ? :magenta : :green
    end

    def action(action, text, &block)
      yield unless dry_run?
      print "#{action}: ".colorize(action_color)
      puts text
    end

  end
end
