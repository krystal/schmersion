# frozen_string_literal: true

require 'schmersion/hosts/github'

module Schmersion
  module Hosts

    HOSTS = [GitHub].freeze

    class << self

      def host_for_url(url)
        HOSTS.each do |host|
          if host.suitable?(url)
            return host.new(url)
          end
        end

        nil
      end

    end

  end
end
