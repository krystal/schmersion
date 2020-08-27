# frozen_string_literal: true

module Schmersion
  class Config

    def initialize(hash)
      @hash = hash
    end

    def types
      @hash['types'] || []
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

      scopes.include?(scokpe.to_s)
    end

    def exports
      return [] if @hash['exports'].nil?

      @hash['exports'].map { |e| create_export(e) }
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
