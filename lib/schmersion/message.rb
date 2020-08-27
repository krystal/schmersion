# frozen_string_literal: true

module Schmersion
  class Message

    REGEX = /^([\w-]+)(?:\(([\w-]+)\))?(!)?:\s(.*?)(?:\(#(\d+)\))?$/.freeze
    FOOTER_COLON_REGEX = /^([\w-]+:|BREAKING CHANGE:)\s*(.*)$/.freeze
    FOOTER_TICKET_REGEX = /^([\w-]+)\s+(#.*)$/.freeze

    attr_reader :header
    attr_reader :footers
    attr_reader :type
    attr_reader :scope
    attr_reader :description
    attr_reader :body
    attr_reader :pull_request_id
    attr_reader :breaking_changes

    def initialize(raw_message)
      @raw_message = clean(raw_message)

      parts = @raw_message.split("\n\n").map(&:strip)

      @header = parts.shift
      @paragraphs = parts
      @breaking_changes = []
      @footers = []

      parse_header
      parse_footers

      @body = @paragraphs.join("\n\n")
    end

    def valid?
      !@type.nil?
    end

    def breaking_change?
      @breaking_change == true ||
        @breaking_changes.size.positive?
    end

    private

    def parse_header
      match = @header.match(REGEX)
      return unless match

      @type = match[1]
      @scope = match[2]
      @description = match[4].strip
      @pull_request_id = match[5]

      @breaking_change = true if match[3] == '!'

      match
    end

    def parse_footers
      footer = []
      @paragraphs.last&.each_line do |line|
        case line.strip
        when FOOTER_COLON_REGEX, FOOTER_TICKET_REGEX
          if footer.any?
            handle_footer(footer)
            footer = []
          end
          footer << "#{Regexp.last_match(1)} #{Regexp.last_match(2)}"
        else
          footer << line.strip
        end
      end

      handle_footer(footer) if footer.any?

      @paragraphs.pop if @footers.any? || @breaking_changes.any?
    end

    def handle_footer(footer_lines = [])
      footer = footer_lines.join("\n")

      if footer.start_with?('BREAKING CHANGE:')
        @breaking_changes << footer.delete_prefix('BREAKING CHANGE:').strip
      else
        @footers << footer
      end
    end

    def clean(message)
      message.sub(/.*-----END PGP SIGNATURE-----\n\n/m, '')
    end

  end
end
