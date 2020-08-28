# frozen_string_literal: true

require 'schmersion/message'
require 'schmersion/message_validator'

module Schmersion
  class Linter

    def initialize(repo)
      @repo = repo
    end

    def prepare(path, source = nil)
      return unless source.nil?

      unless File.file?(path)
        raise Error, "No commit message file at the given path (#{path})"
      end

      header_lines = []
      header_lines << '# ====================================================================='
      header_lines << '# Commit messages must conform to conventional commit formatting.'
      header_lines << '# This means each commit message must be prefixed with an appropriate'
      header_lines << '# type and, optionally, a scope. Your message will be validated before'
      header_lines << '# the commit will be created. '
      header_lines << '#'
      header_lines << '# The following TYPES are available to choose from:'
      header_lines << '#'
      @repo.config.types.sort.each_slice(3) do |names|
        types = names.map { |t| " * #{t.to_s.ljust(16)}" }.join
        header_lines << "# #{types}".strip
      end

      unless @repo.config.scopes.empty?
        header_lines << '#'
        header_lines << '# The following SCOPES are available to choose from:'
        header_lines << '#'
        @repo.config.scopes.sort.each_slice(3) do |names|
          scopes = names.map { |t| " * #{t.to_s.ljust(16)}" }.join
          header_lines << "# #{scopes}".strip
        end
      end

      header_lines << '# ====================================================================='

      header_lines = header_lines.join("\n")

      contents = File.read(path)
      File.write(path, "\n\n#{header_lines}\n#\n#{contents.strip}")
    end

    def validate_file(path)
      unless File.file?(path)
        raise Error, "No commit message file at the given path (#{path})"
      end

      contents = get_commit_message_from_file(File.read(path))
      return [] if contents.length.zero?

      message = Message.new(contents)

      validator = MessageValidator.new(@repo.config, message)
      validator.errors
    end

    def setup(force: false)
      create_hook('lint-prepare', 'prepare-commit-msg', force: force)
      create_hook('lint-validate', 'commit-msg', force: force)
    end

    private

    def get_commit_message_from_file(contents)
      contents = contents.split('------------------------ >8 ------------------------', 2)[0]
      contents.split("\n").reject { |l| l.start_with?('#') }.join("\n").strip
    end

    # Returns the path to schmersion for use in commit files.
    # For production installs, we'll just call it `schmersion` and hope that it is
    # included in the path. For development, we'll use the path to the binary in
    # repository.
    def path_to_schmersion
      if development?
        return File.join(schmersion_root, 'bin', 'schmersion')
      end

      'schmersion'
    end

    def development?
      !File.file?(File.join(schmersion_root, 'VERSION'))
    end

    def schmersion_root
      File.expand_path('../../', __dir__)
    end

    def hook_file_contents(command)
      <<~FILE
        #!/bin/bash

        #{path_to_schmersion} #{command} $1 $2 $3
      FILE
    end

    def create_hook(command, name, force: false)
      hook_path = File.join(@repo.path, '.git', 'hooks', name)
      if File.file?(hook_path) && !force
        raise Error, "Cannot install hook into #{name} because a hook file already exists."
      end

      File.write(hook_path, hook_file_contents(command))
      FileUtils.chmod('u+x', hook_path)
      hook_path
    end

  end
end
