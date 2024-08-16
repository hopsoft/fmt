# frozen_string_literal: true

module Fmt
  class ArgumentsTokenizer < Tokenizer
    # Constructor
    #
    # @note urtext should be restricted to arguments
    #
    # @example
    #   "(80, '.')"
    #
    # @rbs urtext: String -- original source code
    def initialize(urtext)
      super
      @urtext = urtext.to_s
    end

    attr_reader :urtext # :: String -- original source code

    # Tokenizes the urtext (original source code) and extracts argument tokens
    # @rbs return: Array[Fmt::Token] -- Ripper tokens
    def tokenize
      tokens.tap do |list|
        starters = 0
        finishers = 0

        Ripper.lex(urtext).each do |token|
          token = Token.new(token)
          break if starters.positive? && finishers == starters

          starters += 1 if token.arguments_start?
          next if starters.zero?

          finishers += 1 if token.arguments_finish?
          list << token
        end
      end
    end

    private

    def tokenize_callable
      tokens.tap do |list|
        starters = []
        finishers = []
        Ripper.lex(urtext).each do |token|
          token = Token.new(token)
          starters << token if token.arguments_start?
          next if starters.none?
          finishers << token if token.arguments_finish?
          list << token
          break if starters.any? && starters.size == finishers.size
        end
        list.clear if list.map(&:value).join == empty_args_text
      end
    end
  end
end
