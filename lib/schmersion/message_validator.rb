# frozen_string_literal: true

module Schmersion
  class MessageValidator

    attr_reader :errors

    def initialize(config, message)
      @config = config
      @message = message
      @errors = []
      validate_all
    end

    def validate_all
      validate_valid_format
      return unless @message.valid?

      validate_type
      validate_scope
      validate_description_presence
      validate_description_length
    end

    private

    def validate_valid_format
      return if @message.valid?

      errors << 'The commit message is not in a valid format'
    end

    def validate_type
      return if @message.type.nil?
      return if @config.valid_type?(@message.type)

      errors << "Type (#{@message.type}) is not valid"
    end

    def validate_scope
      return if @message.scope.nil?
      return if @config.valid_scope?(@message.scope)

      errors << "Scope (#{@message.scope}) is not valid"
    end

    def validate_description_presence
      return if @message.description&.size&.positive?

      errors << 'A description (text after the type) must be provided'
    end

    def validate_description_length
      return if @message.description.nil?
      return if @message.description.size.zero?
      return if @message.description.size <= @config.linting[:max_description_length]

      errors << "Commit description must be less than #{@config.linting[:max_description_length]} " \
                "characters (currently #{@message.description.size})"
    end

  end
end
