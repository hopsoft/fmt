# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroParser < Parser
    # Constructor
    # @rbs source: String -- source code
    # @rbs return: Fmt::MacroParser
    def initialize(source = "")
      @source = source.to_s
    end

    attr_reader :source # : String -- source code

    protected

    # Parses the source
    # @rbs return: Fmt::MacroAST
    def perform
      @ast ||= cache(source) do
        tokenizer = MacroTokenizer.new(source)
        tokens = tokenizer.tokenize
        key = tokens.first&.value&.to_sym
        block = Fmt.registry[key]

        procedure = ProcedureParser.new(block).parse
        arguments = ArgumentsParser.new(source).parse
        source = [procedure.source, arguments.source].join

        MacroAST.new procedure, arguments, source: source
      end
    end
  end
end
