# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents a callable (i.e. Proc)
  #
  # A Procedure is comprised of:
  # 1. key: Symbol
  # 2. callable: Proc
  #
  class Procedure < Model
    attr_reader :key      # :: Symbol -- key for the Proc in the registry
    attr_reader :callable # :: Proc -- Proc from the registry

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge(
        key: key,
        callable: callable
      )
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    # Processes a procedure AST node
    # @rbs node: Node
    # @rbs return: void
    def on_procedure(node)
      process_all node.children
    end

    # Processes a key AST node
    # @rbs node: Node
    def on_key(node)
      @key = node.find(Symbol)
      @callable = Fmt.registry[key]
    end
  end
end
