# frozen_string_literal: true

require 'spec_helper'
require 'schmersion/message'
require 'schmersion/message_validator'
require 'schmersion/config'

describe Schmersion::MessageValidator do
  subject(:config) { Schmersion::Config.new({}) }

  context 'with a totally invalid message' do
    subject(:validator) { described_class.new(config, Schmersion::Message.new('totally invalid!')) }

    it 'should have a single error' do
      expect(validator.errors).to include 'The commit message is not in a valid format'
    end
  end

  context 'with an invalid type' do
    subject(:validator) { described_class.new(config, Schmersion::Message.new('invalid: add feature')) }

    it 'should have an appropriate error' do
      expect(validator.errors).to include 'Type (invalid) is not valid'
    end
  end

  context 'with an invalid scope' do
    subject(:config) { Schmersion::Config.new('scopes' => ['allowed']) }
    subject(:validator) { described_class.new(config, Schmersion::Message.new('feat(invalid): add feature')) }

    it 'should have an appropriate error' do
      expect(validator.errors).to include 'Scope (invalid) is not valid'
    end
  end

  context 'with a description that is too long' do
    subject(:config) { Schmersion::Config.new('scopes' => ['allowed']) }
    subject(:validator) { described_class.new(config, Schmersion::Message.new("feat: #{'a' * 100}")) }

    it 'should have an appropriate error' do
      expect(validator.errors).to include 'Commit description must be less than 60 characters (currently 100)'
    end
  end
end
