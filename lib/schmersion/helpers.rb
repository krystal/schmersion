# frozen_string_literal: true

module Schmersion
  class Helpers

    class << self

      def print_commit_list(commits, prefix: '')
        commits.each do |commit|
          print prefix
          print '['
          print commit.ref[0, 10].blue
          print ']'
          print ' '
          print commit.message.type.green
          if commit.message.scope
            print '('
            print commit.message.scope.magenta
            print ')'
          end
          if commit.message.breaking_change?
            print ' ! '.white.on_red
          end
          print ': '
          puts commit.message.title
        end
      end

    end

  end
end
