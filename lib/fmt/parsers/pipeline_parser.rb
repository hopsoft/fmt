# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineParser < Parser
    # Constructor
    # @rbs source: String -- source code
    # @rbs return: Fmt::ArgsParser
    def initialize(source = "")
      @source = source.to_s
    end

    attr_reader :source # : String -- source code

    protected

    # Parses the source
    # @rbs return: Fmt::PipelineAST
    def perform
      @ast ||= cache(source) do
        macros = source.split(Sigils::PIPE_OPERATOR).map do |entry|
          MacroParser.new(entry).parse
        end

        source = macros.map(&:source).join(Sigils::PIPE_OPERATOR)

        PipelineAST.new(*macros, source: source)
      end
    end
  end
end
