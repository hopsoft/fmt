# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroAST < AST::Node
    include Composable

    # Constructor
    # @rbs components: Array[Fmt::ProcedureAST | Fmt::ArgumentsAST]
    # @rbs properties: Hash[Symbol, Object]
    # @rbs return: Fmt::MacroAST
    def initialize(*components, **properties)
      assemble(*components, **properties)
      super(:macro, subtree, properties)
    end

    # @rbs return: Fmt::ProcedureAST?
    def callable
      @callable ||= components.find { |c| Fmt::ProcedureAST === c }
    end

    # @rbs return: Fmt::ArgumentsAST?
    def arguments
      @arguments ||= components.find { |c| Fmt::ArgumentsAST === c }
    end

    private

    def subtree
      case [callable&.children, arguments&.children]
      in [[AST::Node], [AST::Node, *]] then [callable, arguments]
      in [[AST::Node], _] then [callable]
      else []
      end
    end
  end
end
