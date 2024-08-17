# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  class TemplateNode < Node
    # Constructor
    # @rbs children: Array[Node] -- [[:key, *], [:pipeline, *], [:embeds, *]]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @key      = children[0]
      @pipeline = children[1]
      @embeds   = children[2]
      super(:template, children, properties)
    end

    attr_reader :key      # :: Node  -- [:key, *]
    attr_reader :pipeline # :: Node  -- [:pipeline, *]
    attr_reader :embeds   # :: Node? -- [:embeds, *]
  end
end
