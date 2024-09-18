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

    attr_reader :urtext # : String -- original source code
    attr_reader :tokens # : Array[Object] -- result of tokenization

    # Tokenizes the urtext (original source code)
    # @rbs return: Array[Token] -- wrapped ripper tokens
    def tokenize
      Ripper.lex(urtext).each do |token|
        tokens << Token.new(token)
      end
    end

    # Returns identifier tokens (typically method names)
    # @rbs start: Integer -- start index
    # @rbs return: Array[Token]
    def identifier_tokens(start: 0)
      tokens[start..].each_with_object([]) do |token, memo|
        break memo if token.arguments_start?
        memo << token if token.identifier?
      end
    end

    def method_tokens(start: 0)
      identifier_tokens + operator_tokens
    end

    # Returns key (named parameter) tokens
    # @rbs start: Integer -- start index
    # @rbs return: Array[Token]?
    def key_tokens(start: 0)
      start = tokens[start..].find(&:key_start?)
      identifier = tokens[tokens.index(start)..].find(&:identifier?) if start
      finish = tokens[tokens.index(identifier)..].find(&:key_finish?) if identifier
      list = [start, identifier, finish].compact

      return [] unless list.size == 3
      return [] unless urtext.include?(list.map(&:value).join)

      list
    end

    # Returns operator tokens
    # @rbs start: Integer -- start index
    # @rbs return: Array[Token]
    def operator_tokens(start: 0)
      tokens[start..].each_with_object([]) do |token, memo|
        break memo if token.arguments_start?
        memo << token if token.operator?
      end
    end

    # Returns the argument tokens
    # @rbs start: Integer -- start index
    # @rbs return: Array[Token]
    def argument_tokens(start: 0)
      starters = 0
      finishers = 0

      tokens[start..].each_with_object([]) do |token, memo|
        break memo if starters.positive? && finishers == starters

        starters += 1 if token.arguments_start?
        next if starters.zero?

        finishers += 1 if token.arguments_finish?
        memo << token
      end
    end
  end
end
