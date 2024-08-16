# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsAST < AST::Node
    include Composable

    # Constructor
    # @rbs children: Array[AST::Node] -- tokens AST node
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @tokens = children.find { _1 in [:tokens, *] }
      super(:arguments, children, properties)
    end

    attr_reader :tokens # :: Array[Fmt::TokenAST]
  end
end
