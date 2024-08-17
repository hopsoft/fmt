# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  class EmbedNode < Node
    # Constructor
    # @rbs children: Array[Node] -- [[:key, *], [:placeholder, *], [:embeds, *]?]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @key         = children[0]
      @placeholder = children[1]
      @embeds      = children[2]
      super(:embed, children, properties)
    end

    attr_reader :key         # :: Node -- (:key, *)
    attr_reader :placeholder # :: Node -- (:placeholder, *)
    attr_reader :embeds      # :: Node? -- (:embeds, *)

    def flatten
      [].tap do |list|
        list << self
        embeds&.children&.each do |embed|
          list.concat embed.flatten
        end
      end
    end
  end
end
