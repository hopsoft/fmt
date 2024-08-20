# frozen_string_literal: true

module Fmt
  # Parser
  #
  # 1) Parses input (Proc) so it can be tokenized
  # 2) Uses a tokenizer to tokenize the parsed value
  # 3) Returns the tokenized AST
  #
  # @example
  #   p = ->(name) { "Hello, #{name}!" }
  #   ProcedureParser.new(p).parse
  #
  class ProcedureParser < Parser
    # Constructor
    # @rbs callable: Proc
    def initialize(callable)
      @callable = callable if callable in Proc
    end

    # Parses the proc (Proc)
    # @rbs return: Node -- (procedure (name Symbol))
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
    # @rbs return: Node -- (procedure (name Symbol))
    def transform(key:)
      return Node.new(:procedure) unless key

      Node.new :procedure, [Node.new(:key, [key])],
        urtext: key.to_s,
        source: key.to_s
    end
  end
end
