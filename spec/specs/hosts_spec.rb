# frozen_string_literal: true

require 'spec_helper'
require 'schmersion/hosts'

describe Schmersion::Hosts do
  context '.host_for_url' do
    it 'return github hosts for github urls' do
      expect(described_class.host_for_url('https://github.com/test/test')).to be_a Schmersion::Hosts::GitHub
    end

    it 'returns nil for unknown urls' do
      expect(described_class.host_for_url('https://google.com')).to be nil
    end
  end
end
