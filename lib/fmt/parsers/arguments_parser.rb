# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses arguments from a string and builds an AST (Abstract Syntax Tree)
  class ArgumentsParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # :: String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      tokenizer = Tokenizer.new(urtext)
      tokenizer.tokenize
      {tokens: tokenizer.argument_tokens}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs tokens: Array[Token] -- extracted tokens
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(tokens:)
      return Node.new(:arguments) if tokens.none?

      tokens = tokens.map { |t| Node.new(t.type, [t.value], urtext: t.value, source: t.value) }
      tokens = Node.new(:tokens, tokens, urtext: urtext, source: tokens.map(&:source).join)

      Node.new :arguments, [tokens], urtext: urtext, source: tokens.source
    end
  end
end
