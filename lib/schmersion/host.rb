# frozen_string_literal: true

module Schmersion
  class Host

    def initialize(url)
      @url = url
    end

    def url_for_commit(commit_ref)
    end

    def url_for_comparison(ref1, ref2)
    end

    class << self

      def suitable?(_)
        false
      end

    end

  end
end
