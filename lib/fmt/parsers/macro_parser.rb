# frozen_string_literal: true

# rbs_inline: enabled

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
      @model = cache(source) do
        tokenizer = MacroTokenizer.new(source)
        tokens = tokenizer.tokenize
        key = tokens.first&.value&.to_sym
        block = Fmt.registry[key]

        if block.is_a? Proc
          MacroAST.new(
            ProcParser.new(block).parse,
            ArgumentsParser.new(source).parse
          )
        else
          MacroAST.stub
        end
      end
    end
  end
end
