# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsAST < AST::Node
    include Composable

    # Constructor
    # @rbs components: Array[Fmt::TokenAST]
    # @rbs properties: Hash[Symbol, Object]
    # @rbs return: Fmt::ArgumentsAST
    def initialize(*components, **properties)
      assemble(*components, **properties)
      super(:arguments, subtree, properties)
    end

    # @rbs return: Array[Fmt::TokenAST]
    def tokens
      @tokens ||= components.select { |c| Fmt::TokenAST === c }
    end

    private

    def subtree
      case tokens
      in Fmt::TokenAST, * then [AST::Node.new(:tokens, tokens)]
      else []
      end
    end
  end
end
