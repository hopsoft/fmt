# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents an uninvoked method call
  #
  # A Macro is comprised of:
  # 1. procedure: Procedure
  # 2. arguments: Arguments
  #
  class Macro < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @args = []
      @kwargs = {}
      super
    end

    attr_reader :procedure # :: Procedure
    attr_reader :arguments # :: Arguments

    # TODO: revisit this and determine if we want to keep it or force going through the other models
    attr_reader :key      # :: Symbol -- method name (key in registry)
    attr_reader :callable # :: Proc
    attr_reader :args     # :: Array[Object] -- positional arguments
    attr_reader :kwargs   # :: Hash[Symbol, Object] -- keyword arguments

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge(
        key: key,
        callable: callable,
        args: args,
        kwargs: kwargs
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
    def on_procedure(node)
      @procedure = Procedure.new(node)
      @key = procedure.key
      @callable = procedure.callable
    end

    # Processes an arguments AST node
    # @rbs node: Node
    # @rbs return: void
    def on_arguments(node)
      @arguments = Arguments.new(node)
      @args = arguments.args
      @kwargs = arguments.kwargs
    end
  end
end
