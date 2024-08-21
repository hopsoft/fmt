# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Ruby source code token extractor
  #
  # Uses Ripper from Ruby's standard library
  # @see https://rubyapi.org/3.4/o/ripper
  # @see doc/RIPPER.md (cheetsheet)
  #
  # @example Ripper token
  #   [[lineno, column], type, token, state]
  #   [[Integer, Integer], Symbol, String, Object]
  #
  class Tokenizer
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext)
      @urtext = urtext.to_s
      @tokens = []
    end

    attr_reader :urtext # :: String -- original source code
    attr_reader :tokens # :: Array[Object] -- result of tokenization

    # Tokenizes the urtext (original source code)
    # @rbs return: Array[Token] -- wrapped ripper tokens
    def tokenize
      Ripper.lex(urtext).each do |token|
        tokens << Token.new(token)
      end
    end

    # Returns leading identifier tokens (before arguments or format specifiers)
    # @rbs return: Array[Token]
    def identifier_tokens
      tokens.each_with_object([]) do |token, memo|
        break memo if token.arguments_start?
        break memo if token.specifier?
        memo << token if token.identifier?
      end
    end

    # Returns the argument tokens
    # @rbs return: Array[Token]
    def argument_tokens
      starters = 0
      finishers = 0

      tokens.each_with_object([]) do |token, memo|
        break memo if starters.positive? && finishers == starters

        starters += 1 if token.arguments_start?
        next if starters.zero?

        finishers += 1 if token.arguments_finish?
        memo << token
      end
    end
  end
end
