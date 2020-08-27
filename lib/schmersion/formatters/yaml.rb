# frozen_string_literal: true

require 'yaml'
require 'schmersion/formatter'

module Schmersion
  module Formatters
    class YAML < Formatter

      DEFAULT_STRUCTURE = [].to_yaml.freeze

      def generate(version)
        commits = version.commits.sort_by { |c| c.message.description.upcase }

        commits = commits.each_with_object([]) do |commit, array|
          next unless include_type?(commit.message.type)

          array << commit_to_hash(commit)
        end

        {
          'version' => version.version.to_s,
          'commits' => commits
        }.to_yaml
      end

      def insert(part)
        unless File.file?(@filename)
          File.write(@filename, DEFAULT_STRUCTURE)
        end

        part_as_hash = ::YAML.safe_load(part)
        existing_yaml = ::YAML.load_file(@filename)
        existing_yaml = [] unless existing_yaml.is_a?(Array)
        existing_yaml.prepend(part_as_hash)
        File.write(@filename, existing_yaml.to_yaml)
      end

      private

      def commit_to_hash(commit)
        {
          'ref' => commit.ref,
          'date' => commit.date.to_s,
          'type' => commit.message.type,
          'scope' => commit.message.scope,
          'description' => commit.message.description,
          'breaking_change' => commit.message.breaking_change?,
          'breaking_changes' => commit.message.breaking_changes,
          'pull_request_id' => commit.message.pull_request_id,
          'footers' => commit.message.footers
        }
      end

      def include_type?(type)
        return true if @options[:types].nil?

        @options[:types].include(type.to_s)
      end

    end
  end
end
