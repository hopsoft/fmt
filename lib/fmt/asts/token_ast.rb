# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TokenAST < AST::Node
    include Composable

    # Constructor
    # @rbs type: Symbol -- Token type
    # @rbs components: Array[String, Symbol] -- [type, value]
    # @rbs properties: Hash[Symbol, Object]
    # @rbs return: Fmt::TokenAST
    def initialize(*components, **properties)
      assemble(*components, **properties)
      super(type || :invalid, subtree, properties)
    end

    # @rbs return: Symbol?
    def type
      @type ||= components.find { |c| Symbol === c }
    end

    # @rbs return: String?
    def value
      @value ||= components.find { |c| String === c }
    end

    private

    def subtree
      [value].compact
    end
  end
end
