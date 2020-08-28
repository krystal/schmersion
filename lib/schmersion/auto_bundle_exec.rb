# frozen_string_literal: true

require 'open3'

module Schmersion
  class AutoBundleExec

    attr_reader :gems
    attr_reader :pwd
    attr_reader :bin
    attr_reader :argv

    def self.when_bundled(gems = [], pwd = Dir.pwd, bin = $PROGRAM_NAME, argv = ARGV)
      return if ENV['BUNDLE_BIN_PATH']

      gems = Array(gems).compact
      return if gems.empty?

      instance = new(gems, pwd, bin, argv)
      return unless instance.bundled_dir?

      instance.re_exec if gems.all? { |gem| instance.bundled?(gem) }
    end

    def initialize(gems, pwd, bin, argv)
      @gems = gems
      @pwd = pwd
      @bin = bin
      @argv = argv
      check_dir
    end

    def bundled_dir?
      @is_bundled_dir
    end

    def bundled?(gem)
      gem_list.include?(" #{gem} ")
    end

    def re_exec
      Kernel.exec(
        { 'SCHMERSION_DISABLE_AUTO_BUNDLE_EXEC' => '1' },
        'bundle', 'exec', bin, *argv
      )
    end

    private

    attr_reader :gem_list

    def check_dir
      @gem_list, status = Open3.capture2e('bundle list')
      @is_bundled_dir = status.success?
    end

  end
end
