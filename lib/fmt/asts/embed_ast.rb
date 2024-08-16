# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class EmbedAST < AST::Node
    include Composable

    # Constructor
    # @rbs children: Array[AST::Node]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @embeds = children[0]
      @key = :"embed_#{properties[:depth]}_#{properties[:index]}"
      super(:embed, [key, embeds], properties)
    end

    attr_reader :embeds # :: AST::Node?
    attr_reader :key    # :: Symbol
  end
end
