# frozen_string_literal: true

module Schmersion
  class Config

    DEFAULT_TYPES = %w[feat fix style chore test refactor perf docs ci build revert].freeze

    DEFAULT_VERSION_OPTIONS = {
      breaking_change_not_major: false
    }.freeze

    DEFAULT_LINTING_OPTIONS = {
      max_description_length: 60
    }.freeze

    def initialize(hash)
      @hash = hash
    end

    def types
      @hash['types'] || DEFAULT_TYPES
    end

    def valid_type?(type)
      return true if types.empty?

      types.include?(type.to_s)
    end

    def scopes
      @hash['scopes'] || []
    end

    def valid_scope?(scope)
      return true if scopes.empty?

      scopes.include?(scope.to_s)
    end

    def exports
      return [] if @hash['exports'].nil?

      @hash['exports'].map { |e| create_export(e) }
    end

    def linting
      DEFAULT_LINTING_OPTIONS.merge(@hash['linting']&.transform_keys(&:to_sym) || {})
    end

    def version_options
      DEFAULT_VERSION_OPTIONS.merge(@hash['version_options']&.transform_keys(&:to_sym) || {})
    end

    private

    def create_export(export)
      name = export['name']
      formatter = Formatters::FORMATTERS[export['formatter'].to_sym]
      if formatter.nil?
        raise Error, "Invalid formatter '#{export['formatter']}' for #{name}"
      end

      formatter.new(name, export['options'] || {})
    end

  end
end
