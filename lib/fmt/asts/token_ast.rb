# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TokenAST < AST::Node
    include Composable

    # Constructor
    # @rbs type: Symbol -- Token type
    # @rbs children: Array[String]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(type, *children, **properties)
      @value = children[0]
      super(type || :invalid, children, properties)
    end

    attr_reader :value # :: String?
  end
end
