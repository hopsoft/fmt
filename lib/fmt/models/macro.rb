# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Macro < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @args = []
      @kwargs = {}
      super
    end

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

    def on_macro(node)
      process_all node.children
    end

    def on_procedure(node)
      procedure = Procedure.new(node)
      @key = procedure.key
      @callable = procedure.callable
    end

    def on_arguments(node)
      arguments = Arguments.new(node)
      @args = arguments.args
      @kwargs = arguments.kwargs
    end
  end
end
