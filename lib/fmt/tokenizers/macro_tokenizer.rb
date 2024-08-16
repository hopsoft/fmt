# frozen_string_literal: true

module Fmt
  class MacroTokenizer < Tokenizer
    # Constructor
    #
    # @note urtext should be restricted to an individual pipeline entry (i.e. macro)
    #
    # @example
    #   "strip"
    #   "ljust(80, '.')"
    #
    # @rbs urtext: String -- original source code
    def initialize(urtext)
      super
      @urtext = urtext.to_s
    end

    attr_reader :urtext # :: String -- original source code

    # Tokenizes the urtext (original source code) and extracts macro tokens
    # @rbs return: Array[Fmt::Token] -- Ripper tokens
    def tokenize
      Ripper.lex(urtext).each do |token|
        break if tokens.any?
        token = Token.new(token)
        next unless token.identifier?
        tokens << token
      end
      tokens
    end
  end
end
