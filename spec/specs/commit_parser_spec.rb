# frozen_string_literal: true

require 'spec_helper'
require 'git'
require 'schmersion/commit_parser'

describe Schmersion::CommitParser do
  context '#parse' do
    describe 'parses all commits from all time' do
      before(:all) do
        @parser = described_class.new(Git.open(EXAMPLE_REPO_PATH), :start, 'cd23926fbd3d44c806ae0e7e1891de25edfa6406')
      end

      specify 'containing all commits' do
        expect(@parser.commits.size).to eq 19
      end

      specify 'containing a latest commit with the correct name' do
        expect(@parser.commits.first.message.header).to eq 'feat: adds widget management'
      end

      specify 'containing the oldest commit with the correct message' do
        expect(@parser.commits.last.message.header).to eq 'docs(readme): add dev details to readme'
      end
    end
  end
end
