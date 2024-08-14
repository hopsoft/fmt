# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Procedure
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin
    include Matchable

    def initialize(ast)
      process ast
    end

    attr_reader :source # :: String -- source code
    attr_reader :name   # :: Symbol -- key for the Proc in the registry
    attr_reader :callable    # :: Proc -- Proc from the registry

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        name: name,
        callable: callable
      }
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def on_procedure(node)
      @source = node.source
      process_all node.children
    end

    def on_name(node)
      @name = node.children.first
      @callable = Fmt.registry[name]
    end
  end
end
