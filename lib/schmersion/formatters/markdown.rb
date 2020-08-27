# frozen_string_literal: true

require 'schmersion/formatter'

module Schmersion
  module Formatters
    class Markdown < Formatter

      def generate(version)
        lines = []
        lines << "## #{version.version}\n"

        sections_for_commits(version.commits).each do |section, commits|
          lines << "### #{section['description']}\n"
          commits.each do |commit|
            first_line = '- '
            first_line += "**#{commit.message.scope}:** " if commit.message.scope
            first_line += capitalize_as_required(commit.message.description)
            lines << first_line
            commit.message.footers.each do |footer|
              lines << "  #{capitalize_as_required(footer)}\n"
            end
          end
          lines << nil
        end
        lines.join("\n")
      end

      def insert(part)
        text_to_insert = "#{header}\n#{part}"

        unless File.file?(@filename)
          File.write(@filename, text_to_insert)
          return
        end

        # If we already have a changelog markdown file, we're going to remove
        # everyting up to the first level 2 heading and replace it with the
        # header and the new version's data.
        contents = File.read(@filename)
        contents_without_header = contents.sub(/\A.*?##/m, '##')
        File.write(@filename, "#{text_to_insert}\n#{contents_without_header}")

        true
      end

      private

      def header
        lines = []
        lines << "# #{@options['description']}\n"
        lines << @options['description'] if @options['description']
        lines << nil
        lines.join("\n")
      end

      def sections_for_commits(commits)
        return [] if @options['sections'].empty?

        @options['sections'].each_with_object([]) do |section, array|
          section_commits = commits.select do |commit|
            section['types'].nil? ||
              !section['types'].is_a?(Array) ||
              section['types'].include?(commit.message.type)
          end

          next if section_commits.empty?

          section_commits = section_commits.sort_by { |c| c.message.description.upcase }

          array << [section, section_commits]
        end
      end

      def capitalize_as_required(string)
        return string unless @options['capitalize_strings']

        string.sub(/\A([a-z])/) { Regexp.last_match(1).upcase }
      end

    end
  end
end
