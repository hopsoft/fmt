# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # : String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- (macro (procedure (name Symbol)) (arguments (tokens (Symbol, String), *)))
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Array[Node?, Node?] -- [procedure, arguments]
    def extract
      tokenizer = Tokenizer.new(urtext)
      tokenizer.tokenize

      identifiers = tokenizer.identifier_tokens.map(&:value)
      key = identifiers.last&.to_sym
      key = Sigils::FORMAT_METHOD unless key && Fmt.registry.key?(key)

      {
        key: key,
        tokens: tokenizer.tokens
      }
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs key: Symbol?
    # @rbs tokens: Array[Token]
    # @rbs return: Node -- (macro (procedure (name Symbol)) (arguments (tokens (Symbol, String), *)))
    def transform(key:, tokens:)
      source = case key
      in Sigils::FORMAT_METHOD then "#{key}(%Q[%#{urtext}])"
      else urtext
      end

      children = [
        ProcedureParser.new(Fmt.registry[key]).parse,
        ArgumentsParser.new(source).parse
      ]

      Node.new :macro, children.reject(&:empty?),
        urtext: urtext,
        source: source
    end
  end
end
