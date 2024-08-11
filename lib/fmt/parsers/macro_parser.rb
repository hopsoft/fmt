# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../asts/macro_ast"
require_relative "../tokenizers/macro_tokenizer"
require_relative "arguments_parser"
require_relative "parser"
require_relative "proc_parser"

module Fmt
  class MacroParser < Parser
    # Constructor
    # @rbs source: String -- source code string
    # @rbs return: Fmt::MacroParser
    def initialize(source = "")
      @source = source.to_s
    end

    attr_reader :source # : String -- string being parsed

    protected

    # Parses the source
    # @rbs return: Fmt::MacroModel
    def perform
      @model = Cache.fetch(source) do
        tokenizer = MacroTokenizer.new(source)
        tokens = tokenizer.tokenize
        key = tokens.first&.value&.to_sym
        block = Fmt.registry[key]

        return MacroAST.stub unless block.is_a?(Proc)

        MacroAST.new(
          ProcParser.new(block).parse,
          ArgumentsParser.new(source).parse
        )
      end
    end
  end
end
