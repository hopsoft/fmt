# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Macro
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin
    include Matchable

    def initialize(ast)
      @args = []
      @kwargs = {}
      process ast
    end

    attr_reader :source   # :: String -- source code
    attr_reader :name     # :: Symbol -- method name (key in registry)
    attr_reader :callable # :: Proc
    attr_reader :args     # :: Array[Object] -- positional arguments
    attr_reader :kwargs   # :: Hash[Symbol, Object] -- keyword arguments

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        name: name,
        callable: callable,
        args: args,
        kwargs: kwargs
      }
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def on_macro(node)
      @source = node.source
      process_all node.children
    end

    def on_procedure(node)
      procedure = Procedure.new(node)
      @name = procedure.name
      @callable = procedure.callable
    end

    def on_arguments(node)
      arguments = Arguments.new(node)
      @args = arguments.args
      @kwargs = arguments.kwargs
    end
  end
end
