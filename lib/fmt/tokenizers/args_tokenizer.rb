# frozen_string_literal: true

module Fmt
  class ArgsTokenizer < Tokenizer
    # Constructor
    #
    # @note Source should be strictly limited to arguments
    #
    # @example
    #   "(80, '.')"
    #
    # @rbs source: String -- source code to tokenize
    # @rbs return: Fmt::ArgsLexer
    def initialize(source)
      super
      @source = source.to_s
    end

    attr_reader :source # :: String

    # Tokenizes the source string and extracts argument tokens
    # @note Preserves the Ripper token names
    def tokenize
      Ripper.lex(source).each do |token|
        next if arguments_begin?(token)
        next if arguments_finish?(token)
        tokens << token
      end
    end

    # Converts the result of tokenization to an AST
    # @rbs return: AST::Node
    def to_ast
      ast_node :args, tokens_to_ast, source: source
    end
  end
end
