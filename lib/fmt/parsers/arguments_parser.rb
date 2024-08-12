# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsParser < Parser
    PREFIX = /(?=\()/
    SUFFIX = /\)/

    # Constructor
    # @rbs source: String -- source code string
    # @rbs return: Fmt::ArgsParser
    def initialize(source = "")
      @source = source.to_s
    end

    attr_reader :source # : String -- string being parsed

    protected

    # Parses the source
    # @rbs return: Fmt::ArgsModel
    def perform
      @model = cache(source) do
        scanner = StringScanner.new(source)
        scanner.skip_until PREFIX
        parsed = scanner.scan_until(SUFFIX) if scanner.matched?

        tokenizer = ArgumentsTokenizer.new(parsed.to_s)
        tokens = tokenizer.tokenize

        ArgumentsAST.new(*tokens)
      end
    end
  end
end
