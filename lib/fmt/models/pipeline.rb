# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents a series of Macros
  #
  # A Pipeline is comprised of:
  # 1. macros: Array[Macro]
  #
  # @note Pipelines are processed in sequence (left to right)
  #
  class Pipeline < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @macros = []
      super
    end

    attr_reader :macros # : Array[Node]

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge macros: macros.map(&:to_h)
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    # Processes a pipeline AST node
    # @rbs node: Node
    # @rbs return: void
    def on_pipeline(node)
      process_all node.children
    end

    # Processes a macro AST node
    # @rbs node: Node
    # @rbs return: void
    def on_macro(node)
      @macros << Macro.new(node)
    end
  end
end
