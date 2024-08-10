# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgsParser < Parser
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

    # Parses the source string and returns an AST for tokenized arguments
    # @rbs return: AST::Node
    def perform
      @value = Cache.fetch(source) do
        scanner = StringScanner.new(source)
        scanner.skip_until PREFIX
        parsed = scanner.scan_until(SUFFIX) if scanner.matched?
        tokenizer = ArgsTokenizer.new(parsed.to_s)
        tokenizer.tokenize
        tokenizer.to_ast
      end
    end
  end
end
