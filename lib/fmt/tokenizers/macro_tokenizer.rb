# frozen_string_literal: true

module Fmt
  class MacroTokenizer < Tokenizer
    # Constructor
    #
    # @note Source should be strictly limited to an individual pipeline entry (i.e. macro)
    #
    # @example
    #   "strip"
    #   "ljust(80, '.')"
    #
    # @rbs source: String -- source code to tokenize
    # @rbs return: Fmt::MacroTokenizer
    def initialize(source)
      super
      @source = source.to_s
    end

    attr_reader :source # :: String

    # Tokenizes the source string and extracts macro tokens
    # @rbs return: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens
    def tokenize
      super do
        Ripper.lex(source).each do |token|
          break if tokens.any?
          token = TokenModel.new(token)
          next unless token.identifier?
          tokens << token
        end
      end
    end
  end
end
