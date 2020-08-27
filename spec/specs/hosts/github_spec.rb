# frozen_string_literal: true

require 'spec_helper'
require 'schmersion/hosts/github'

describe Schmersion::Hosts::GitHub do
  context '.suitable?' do
    [
      'git@github.com:example/test',
      'git@github.com:example/test.git',
      'https://github.com/example/test',
      'https://github.com/example/test.git'
    ].each do |url|
      it "supports #{url}" do
        expect(described_class.suitable?(url)).to be true
      end
    end
  end

  context '#url_for_commit' do
    it 'returns a URL' do
      host = described_class.new('git@github.com:krystal/schmersion')
      expect(host.url_for_commit('abcdef123')).to eq 'https://github.com/krystal/schmersion/commit/abcdef123'
    end
  end
end
