# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineParser < Parser
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
        macro_asts = source.split(Sigils::PIPE_OPERATOR).map do |chunk|
          MacroParser.new(chunk).parse
        end

        PipelineAST.new(*macro_asts)
      end
    end
  end
end
