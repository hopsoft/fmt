# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
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

    def on_procedure(node)
      process_all node.children
    end

    def on_key(node)
      @key = node.find(Symbol)
      @callable = Fmt.registry[key]
    end
  end
end
