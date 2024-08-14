# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcedureAST < AST::Node
    include Composable

    # Constructor
    # @rbs components: Array[AST::Node]
    # @rbs properties: Hash[Symbol, Object]
    # @rbs return: Fmt::ProcedureAST
    def initialize(*components, **properties)
      assemble(*components, **properties)
      super(:procedure, subtree, properties)
    end

    # @rbs return: AST::Node?
    def name
      @name ||= components.find do |c|
        AST::Node === c && c.type == :name
      end
    end

    def subtree
      [name].compact
    end
  end
end
