# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses arguments from a string and builds an AST (Abstract Syntax Tree)
  class ArgumentsParser < Parser
    # Constructor
    # @rbs tokens: Array[Token] -- wrapped ripper tokens
    def initialize(tokens = [])
      @tokens = tokens
    end

    attr_reader :tokens # : Array[Token] -- wrapped ripper tokens

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(tokens.to_s) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      {tokens: tokens}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs tokens: Array[Token] -- extracted tokens
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(tokens:)
      return Node.new(:arguments) if tokens.none?

      source = tokens.map(&:value).join
      tokens = tokens.map { |t| Node.new(t.type, [t.value], urtext: t.value, source: t.value) }
      tokens = Node.new(:tokens, tokens, urtext: source, source: source)

      Node.new :arguments, [tokens], urtext: source, source: source
    end
  end
end
