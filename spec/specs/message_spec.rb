# frozen_string_literal: true

require 'spec_helper'
require 'schmersion/message'

describe Schmersion::Message do
  context 'with an invalid commit message' do
    subject(:message) { described_class.new('an invalid message') }

    it 'is not valid' do
      expect(message.valid?).to be false
    end

    it 'has no type' do
      expect(message.type).to be nil
    end

    it 'has no scope' do
      expect(message.scope).to be nil
    end

    it 'has a header matching the commit' do
      expect(message.header).to eq 'an invalid message'
    end

    it 'has no footers' do
      expect(message.footers).to be_empty
    end
  end

  context 'with a type and no scope' do
    subject(:message) { described_class.new('feat: an example feature') }

    it 'is valid' do
      expect(message.valid?).to be true
    end

    it 'has the correct type' do
      expect(message.type).to eq 'feat'
    end

    it 'has no scope' do
      expect(message.scope).to be nil
    end

    it 'has the correct description' do
      expect(message.description).to eq 'an example feature'
    end

    it 'has a header matching the commit' do
      expect(message.header).to eq 'feat: an example feature'
    end

    it 'has no footers' do
      expect(message.footers).to be_empty
    end
  end

  context 'with a type and scope' do
    subject(:message) { described_class.new('feat(factory): an example feature') }

    it 'is valid' do
      expect(message.valid?).to be true
    end

    it 'has the correct type' do
      expect(message.type).to eq 'feat'
    end

    it 'has the correct scope' do
      expect(message.scope).to eq 'factory'
    end

    it 'has the correct description' do
      expect(message.description).to eq 'an example feature'
    end

    it 'has a header matching the commit' do
      expect(message.header).to eq 'feat(factory): an example feature'
    end

    it 'has no footers' do
      expect(message.footers).to be_empty
    end
  end

  context 'with a type, scope, header and some footers' do
    subject(:message) do
      message = <<~MESSAGE
        fix(users): fixes user logins

        This fixes some user login issues which were present

        Something else in the body here which is split onto multiple
        lines in the commit for ease of use.

        Signed-off-by: John Smith <john@example.com>
        Signed-off-by: Jane Smith <jane@example.com>
        Ticket #2392
        Reviewed-on:2020-08-27
        Review-summary: The fix looks good, but I believe we need to
        expand the test suite to cover additional user login issues.
        Reviewed-by:   Jack Smith <jack@example.com>
      MESSAGE
      described_class.new(message)
    end

    it 'is valid' do
      expect(message.valid?).to be true
    end

    it 'has the correct type' do
      expect(message.type).to eq 'fix'
    end

    it 'has the correct scope' do
      expect(message.scope).to eq 'users'
    end

    it 'has the correct description' do
      expect(message.description).to eq 'fixes user logins'
    end

    it 'has a header matching the commit' do
      expect(message.header).to eq 'fix(users): fixes user logins'
    end

    it 'has a body matching the commit' do
      expect(message.body).to eq <<~BODY.strip
        This fixes some user login issues which were present

        Something else in the body here which is split onto multiple
        lines in the commit for ease of use.
      BODY
    end

    it 'has appropriate footers' do
      expect(message.footers).to eq [
        'Signed-off-by: John Smith <john@example.com>',
        'Signed-off-by: Jane Smith <jane@example.com>',
        'Ticket #2392',
        'Reviewed-on: 2020-08-27',
        "Review-summary: The fix looks good, but I believe we need to\n" \
        'expand the test suite to cover additional user login issues.',
        'Reviewed-by: Jack Smith <jack@example.com>'
      ]
    end
  end

  context 'with a breaking change bang' do
    subject(:message) { described_class.new('feat(factory)!: an example feature') }

    it 'is valid' do
      expect(message.valid?).to be true
    end

    it 'has the correct type' do
      expect(message.type).to eq 'feat'
    end

    it 'has the correct scope' do
      expect(message.scope).to eq 'factory'
    end

    it 'has the correct description' do
      expect(message.description).to eq 'an example feature'
    end

    it 'has a header matching the commit' do
      expect(message.header).to eq 'feat(factory)!: an example feature'
    end

    it 'has no footers' do
      expect(message.footers).to be_empty
    end

    it 'has the breaking change boolean set' do
      expect(message.breaking_change?).to be true
    end
  end

  context 'with a breaking change footer' do
    subject(:message) do
      message = <<~MESSAGE
        refactor(ruby): remove support for ruby 2.5

        BREAKING CHANGE: This will no longer work with Ruby 2.5
      MESSAGE
      described_class.new(message)
    end

    it 'is valid' do
      expect(message.valid?).to be true
    end

    it 'has the correct type' do
      expect(message.type).to eq 'refactor'
    end

    it 'has the correct scope' do
      expect(message.scope).to eq 'ruby'
    end

    it 'has the correct description' do
      expect(message.description).to eq 'remove support for ruby 2.5'
    end

    it 'has a header matching the commit' do
      expect(message.header).to eq 'refactor(ruby): remove support for ruby 2.5'
    end

    it 'has no footers' do
      expect(message.footers).to be_empty
    end

    it 'returns true for breaking change' do
      expect(message.breaking_change?).to be true
    end

    it 'has list of breaking change descriptions' do
      expect(message.breaking_changes).to eq [
        'This will no longer work with Ruby 2.5'
      ]
    end
  end

  context 'with multiple breaking change footers' do
    subject(:message) do
      message = <<~MESSAGE
        refactor(ruby): remove support for ruby 2.5

        BREAKING CHANGE: This will no longer work with Ruby 2.5
        BREAKING CHANGE: fancy_gem version 4.x or later is now required
      MESSAGE
      described_class.new(message)
    end

    it 'is valid' do
      expect(message.valid?).to be true
    end

    it 'returns true for breaking change' do
      expect(message.breaking_change?).to be true
    end

    it 'has list of breaking change descriptions' do
      expect(message.breaking_changes).to eq [
        'This will no longer work with Ruby 2.5',
        'fancy_gem version 4.x or later is now required'
      ]
    end
  end
end
