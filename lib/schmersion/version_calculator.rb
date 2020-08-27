# frozen_string_literal: true

require 'semantic'

module Schmersion
  class VersionCalculator

    def initialize(current, commits, **options)
      if current.is_a?(String)
        current = Semantic::Version.new(current)
      end

      @current = current || Semantic::Version.new('1.0.0')
      @commits = commits
      @options = options
    end

    def calculate
      if @current.pre && pre?
        new_version = @current.dup
      elsif breaking_changes? && consider_breaking_changes_major? && @current.major.positive?
        new_version = @current.increment!(:major)
      elsif features? || breaking_changes?
        new_version = @current.increment!(:minor)
      else
        new_version = @current.increment!(:patch)
      end

      add_pre_to_version(new_version) if @options[:pre]

      new_version
    end

    private

    def pre?
      !!@options[:pre]
    end

    def features?
      @commits.any? { |c| c.message.type == 'feat' }
    end

    def breaking_changes?
      @commits.any? { |c| c.message.breaking_change? }
    end

    def consider_breaking_changes_major?
      return false if @options[:breaking_change_not_major]

      true
    end

    def add_pre_to_version(version)
      prefix = @options[:pre]
      prefix = 'pre' unless prefix.is_a?(String)

      current_prefix, current_sequence = @current&.pre&.split('.', 2)
      if current_prefix == prefix
        # If the current version's prefix is the same as the one
        # that's been selected, we'll increment its integer
        pre_sequence = current_sequence.to_i + 1
      else
        pre_sequence = 1
      end
      version.pre = "#{prefix}.#{pre_sequence}"
      version
    end

  end
end
