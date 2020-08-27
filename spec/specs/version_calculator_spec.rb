# frozen_string_literal: true

require 'spec_helper'
require 'schmersion/version_calculator'

describe Schmersion::VersionCalculator do
  context 'with a starting version of 1.0.0 and a range of commits containing features' do
    subject(:calc) do
      described_class.new('1.0.0', [
                            Schmersion::Commit.new(FakeCommit.new('feat: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ])
    end

    it 'will increment the minor part' do
      expect(calc.calculate.to_s).to eq '1.1.0'
    end
  end

  context 'with a current version of 1.0.0 and a rnage of commits not containing features' do
    subject(:calc) do
      described_class.new('1.0.0', [
                            Schmersion::Commit.new(FakeCommit.new('fix: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ])
    end

    it 'will increment the patch part' do
      expect(calc.calculate.to_s).to eq '1.0.1'
    end
  end

  context 'with a current version of 1.3.1 and a rnage of commits containing a breaking change' do
    subject(:calc) do
      described_class.new('1.3.1', [
                            Schmersion::Commit.new(FakeCommit.new('fix!: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ])
    end

    it 'will increment the major part' do
      expect(calc.calculate.to_s).to eq '2.0.0'
    end
  end

  context 'with a current version of 0.0.1 and a range of commits containing features and a breaking change' do
    subject(:calc) do
      described_class.new('0.0.1', [
                            Schmersion::Commit.new(FakeCommit.new('fix!: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ])
    end

    it 'will not increment the major, just the minor' do
      expect(calc.calculate.to_s).to eq '0.1.0'
    end
  end

  context 'with a current version of 1.2.3 and a range of commits containing only fixes and a pre option' do
    subject(:calc) do
      described_class.new('1.2.3', [
                            Schmersion::Commit.new(FakeCommit.new('fix: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ], pre: 'beta')
    end

    it 'will increment the patch part and start the pre at 1' do
      expect(calc.calculate.to_s).to eq '1.2.4-beta.1'
    end
  end

  context 'with a current version of 1.2.3 and a range of commits containing features and a pre option' do
    subject(:calc) do
      described_class.new('1.2.3', [
                            Schmersion::Commit.new(FakeCommit.new('feat: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ], pre: 'beta')
    end

    it 'will increment the patch part and start the pre at 1' do
      expect(calc.calculate.to_s).to eq '1.3.0-beta.1'
    end
  end

  context 'with a current version of 2.0.0-beta.4 and a range of commits with features and a pre option' do
    subject(:calc) do
      described_class.new('2.0.0-beta.4', [
                            Schmersion::Commit.new(FakeCommit.new('feat: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ], pre: 'beta')
    end

    it 'will increment the pre sequence' do
      expect(calc.calculate.to_s).to eq '2.0.0-beta.5'
    end
  end

  context 'with a current version of 2.0.0-beta.4 and a range of commits with features and a different pre option' do
    subject(:calc) do
      described_class.new('2.0.0-beta.4', [
                            Schmersion::Commit.new(FakeCommit.new('feat: example feature')),
                            Schmersion::Commit.new(FakeCommit.new('fix: another fix'))
                          ], pre: 'rc')
    end

    it 'will start the pre sequence from 1' do
      expect(calc.calculate.to_s).to eq '2.0.0-rc.1'
    end
  end
end
