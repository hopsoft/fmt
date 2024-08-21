# frozen_string_literal: true

module Fmt
  # Parses a procedure from a callable (Proc) and builds an AST (Abstract Syntax Tree)
  class ProcedureParser < Parser
    # Constructor
    # @rbs callable: Proc
    def initialize(callable)
      @callable = callable if callable in Proc
    end

    # Parses the proc (Proc)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(callable.hash) { super }
    end

    protected

    attr_reader :callable # :: Proc?

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Symbol?]
    def extract
      {key: Fmt.registry.key_for(callable)}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs key: Symbol -- registry key for the callable (method name)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(key:)
      return Node.new(:procedure) unless key

      Node.new :procedure, [Node.new(:key, [key])],
        urtext: key.to_s,
        source: key.to_s
    end
  end
end
