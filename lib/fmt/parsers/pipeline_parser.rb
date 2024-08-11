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
      @model = Cache.fetch(source) do
        source.split(Sigils::PIPE_OPERATOR).map do |source|
        end
      end
    end
  end
end
