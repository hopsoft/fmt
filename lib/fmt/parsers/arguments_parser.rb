# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsParser < Parser
    PREFIX = /(?=\()/
    SUFFIX = /\)/

    # Constructor
    # @rbs source: String -- source code
    # @rbs return: Fmt::ArgsParser
    def initialize(source = "")
      @source = source.to_s
    end

    attr_reader :source # : String -- source code

    protected

    # Parses the source
    # @rbs return: Fmt::ArgumentsAST
    def perform
      @ast ||= cache(source) do
        scanner = StringScanner.new(source)
        scanner.skip_until PREFIX
        parsed = scanner.scan_until(SUFFIX) if scanner.matched?

        tokenizer = ArgumentsTokenizer.new(parsed.to_s)
        tokens = tokenizer.tokenize
        components = tokens.map do |token|
          TokenAST.new(token.type, token.value, urtext: source, source: token.value)
        end

        ArgumentsAST.new(*components, urtext: source, source: tokens.map(&:value).join)
      end
    end
  end
end
