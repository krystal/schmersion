# frozen_string_literal: true

module Schmersion
  class Message

    REGEX = /^([\w-]+)(?:\(([\w-]+)\))?(!)?:\s(.*?)(?:\(#(\d+)\))?$/.freeze

    attr_reader :header
    attr_reader :footers
    attr_reader :type
    attr_reader :scope
    attr_reader :title
    attr_reader :pull_request_id
    attr_reader :breaking_changes

    def initialize(raw_message)
      @raw_message = clean(raw_message)

      parts = @raw_message.split("\n\n").map do |p|
        p.strip.gsub("\n", ' ')
      end

      @header = parts.shift
      @footers = parts
      @breaking_changes = []

      parse_header
      parse_footers
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
      @title = match[4].strip
      @pull_request_id = match[5]

      @breaking_change = true if match[3] == '!'

      match
    end

    def parse_footers
      @footers.reject! do |footer|
        breaking_change_match = footer.match(/^BREAKING CHANGE:(.*)/i)
        if breaking_change_match
          @breaking_changes << breaking_change_match[1].strip
          true
        else
          false
        end
      end
    end

    def clean(message)
      message.sub(/.*-----END PGP SIGNATURE-----\n\n/m, '')
    end

  end
end
