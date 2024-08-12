# frozen_string_literal: true

module Fmt
  class ArgumentsTokenizer < Tokenizer
    # Constructor
    #
    # @note Source should be strictly limited to arguments
    #
    # @example
    #   "(80, '.')"
    #
    # @rbs source: String -- source code to tokenize
    # @rbs return: Fmt::ArgsTokenizer
    def initialize(source)
      super
      @source = source.to_s
    end

    attr_reader :source # :: String

    # Tokenizes the source string and extracts argument tokens
    # @rbs return: Array[Fmt::RipperToken] -- Ripper tokens
    def tokenize
      super do
        started = false

        Ripper.lex(source).each do |token|
          token = TokenModel.new(token)
          next unless started ||= token.arguments_start?
          tokens << token
          break if token.arguments_finish?
        end
      end
    end
  end
end
