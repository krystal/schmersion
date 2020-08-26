# frozen_string_literal:  true

require 'schmersion/message'

module Schmersion
  class Commit

    attr_reader :message
    attr_reader :ref
    attr_reader :date
    attr_reader :author
    attr_reader :raw_commit

    def initialize(commit)
      @message = Message.new(commit.message)
      @ref = commit.sha
      @date = commit.date
      @author = commit.author.name
      @raw_commit = commit
    end

  end
end
