# frozen_string_literal: true

require 'schmersion/host'

module Schmersion
  module Hosts
    class GitHub < Host

      SSH_REGEXP = /\Agit@github\.com:([\w-]+)\/([\w-]+)(\.git)?\z/.freeze
      HTTP_REGEXP = /\Ahttps:\/\/github\.com\/([\w-]+)\/([\w-]+)(\.git)?\z/.freeze

      class << self

        def suitable?(url)
          !!(url.match(SSH_REGEXP) || url.match(HTTP_REGEXP))
        end

      end

      def initialize(url)
        super
        get_user_and_repo(url)
        @base_url = "https://github.com/#{@user}/#{@repo}"
      end

      def url_for_commit(ref)
        "#{@base_url}/commit/#{ref}"
      end

      def url_for_comparison(ref1, ref2)
        "#{@base_url}/compare/#{ref1}..#{ref2}"
      end

      private

      def get_user_and_repo(url)
        if m = url.match(SSH_REGEXP)
          @user = m[1]
          @repo = m[2]
        elsif m = url.match(HTTP_REGEXP)
          @user = m[1]
          @repo = m[2]
        else
          raise Error, 'Could not determine appropriate details for repository from URL'
        end
      end

    end
  end
end
