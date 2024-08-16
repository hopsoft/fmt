# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcedureAST < AST::Node
    include Composable

    # Constructor
    # @rbs children: Array[AST::Node]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @name = children.find { _1 in [:name, *] }
      super(:procedure, children, properties)
    end

    attr_reader :name # :: Symbol?
  end
end
