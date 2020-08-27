# frozen_string_literal: true

require 'schmersion/formatters/markdown'
require 'schmersion/formatters/yaml'

module Schmersion
  module Formatters

    FORMATTERS = {
      yaml: YAML,
      markdown: Markdown
    }.freeze

  end
end
