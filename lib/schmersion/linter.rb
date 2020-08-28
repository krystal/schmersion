# frozen_string_literal: true

require 'schmersion/message'
require 'schmersion/message_validator'

module Schmersion
  class Linter

    def initialize(repo)
      @repo = repo
    end

    def prepare(path, source = nil)
      previous_commit_message = read_previous_commit_message

      return unless source.nil?

      unless File.file?(path)
        raise Error, "No commit message file at the given path (#{path})"
      end

      lines = []

      if previous_commit_message
        lines << previous_commit_message
        lines << ''
      else
        lines << "\n"
      end

      lines << '# ====================================================================='
      lines << '# Commit messages must conform to conventional commit formatting.'
      lines << '# This means each commit message must be prefixed with an appropriate'
      lines << '# type and, optionally, a scope. Your message will be validated before'
      lines << '# the commit will be created. '
      lines << '#'

      add_list_for(lines, :types)

      unless @repo.config.scopes.empty?
        lines << '#'
        add_list_for(lines, :scopes)
      end

      lines << '# ====================================================================='

      lines = lines.join("\n")

      contents = File.read(path)
      File.write(path, "#{lines}\n#\n#{contents.strip}")
    end

    def validate_file(path)
      unless File.file?(path)
        raise Error, "No commit message file at the given path (#{path})"
      end

      contents = get_commit_message_from_file(File.read(path))
      return [] if contents.length.zero?

      message = Message.new(contents)

      validator = MessageValidator.new(@repo.config, message)

      unless validator.valid?
        # Save the commit message to a file if its invalid.
        save_commit_message(contents)
      end

      validator.errors
    end

    def setup(force: false)
      create_hook('lint-prepare', 'prepare-commit-msg', force: force)
      create_hook('lint-validate', 'commit-msg', force: force)
    end

    private

    def read_previous_commit_message
      path = '.git/SCHMERSION_EDITMSG'
      if File.file?(path)
        contents = File.read(path)
        FileUtils.rm(path)
        contents
      end
    end

    def save_commit_message(message)
      File.write('.git/SCHMERSION_EDITMSG', message)
    end

    def add_list_for(lines, type)
      lines << "# The following #{type.to_s.upcase} are available to choose from:"
      lines << '#'
      @repo.config.public_send(type).sort.each_slice(3) do |names|
        types = names.map { |t| " * #{t.to_s.ljust(16)}" }.join
        lines << "# #{types}".strip
      end
    end

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
