# frozen_string_literal: true

module Schmersion
  class Formatter

    attr_reader :filename

    def initialize(filename, options = {})
      @filename = filename
      @options = options
    end

    # Generate the output which should be included in the export. This
    # should return a string which will also be displayed when doing
    # dry-runs of a release.
    # rubocop:disable Lint/UnusedMethodArgument
    def generate(repo, version)
      ''
    end
    # rubocop:enable Lint/UnusedMethodArgument

    # Insert a given part into the given source file path
    #
    # @param part [String]
    # @return [void]
    def insert(part)
    end

  end
end
