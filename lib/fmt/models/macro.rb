# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents an uninvoked method call
  #
  # A Macro is comprised of:
  # 1. name: Symbol
  # 2. arguments: Arguments
  #
  class Macro < Model
    attr_reader :name      # :: Symbol -- method name
    attr_reader :arguments # :: Arguments

    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @name = nil
      @arguments = Arguments.new(Node.new(:arguments))
      super
    end

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge(
        name: name,
        arguments: arguments&.to_h
      )
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    # Processes a macro AST node
    # @rbs node: Node
    # @rbs return: void
    def on_macro(node)
      process_all node.children
    end

    # Processes a procedure AST node
    # @rbs node: Node
    # @rbs return: void
    def on_name(node)
      @name = node.find(Symbol)
    end

    # Processes an arguments AST node
    # @rbs node: Node
    # @rbs return: void
    def on_arguments(node)
      @arguments = Arguments.new(node)
    end
  end
end
