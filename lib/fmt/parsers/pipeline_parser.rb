# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # : String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- (pipeline (macro (procedure (name Symbol)) (arguments (tokens (Symbol, String), *))), *)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      {macros: urtext.split(Sigils::PIPE_OPERATOR)}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs macros: Array[String] -- extracted components
    # @rbs return: Node -- (pipeline (macro (procedure (name Symbol)) (arguments (tokens (Symbol, String), *))), *)
    def transform(macros:)
      macros = macros.map { |m| MacroParser.new(m).parse }.reject(&:empty?)

      Node.new :pipeline, macros,
        urtext: urtext,
        source: macros.map(&:source).join(Sigils::PIPE_OPERATOR)
    end
  end
end
