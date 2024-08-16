# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroAST < AST::Node
    include Composable

    # Constructor
    # @rbs children: Array[Fmt::ProcedureAST, Fmt::ArgumentsAST]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @procedure = children.find { _1 in Fmt::ProcedureAST }
      @arguments = children.find { _1 in Fmt::ArgumentsAST }
      super(:macro, children, properties)
    end

    attr_reader :procedure # :: Fmt::ProcedureAST?
    attr_reader :arguments # :: Fmt::ArgumentsAST?
  end
end
