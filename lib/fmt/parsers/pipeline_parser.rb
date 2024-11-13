# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a pipeline from a string and builds an AST (Abstract Syntax Tree)
  class PipelineParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "?")
    end

    attr_reader :urtext  # : String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      macros = urtext.split(Sigils::PIPE_OPERATOR).map(&:strip).reject(&:empty?)
      {macros: macros}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs macros: Array[Array[Token]] -- extracted macro tokens
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(macros:)
      macros = macros.map { |macro_urtext, memo| MacroParser.new(macro_urtext).parse }.reject(&:empty?)
      source = macros.map(&:source).join(Sigils::PIPE_OPERATOR).strip

      Node.new :pipeline, macros, urtext: urtext, source: source
    end
  end
end
