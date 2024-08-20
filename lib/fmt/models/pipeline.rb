# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Pipeline < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @macros = []
      super
    end

    attr_reader :macros # :: Array[Node]

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge macros: macros.map(&:to_h)
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def on_pipeline(node)
      process_all node.children
    end

    def on_macro(node)
      @macros << Macro.new(node)
    end
  end
end
