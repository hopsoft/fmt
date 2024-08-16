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

    protected

    # Parses the urtext (original source code)
    # @rbs return: AST::Node
    def perform
      cache urtext do
        # 1) build the AST children
        list = urtext.split(Sigils::PIPE_OPERATOR)
        macros = list.each_with_object([]) do |entry, memo|
          next if entry.empty?
          memo << MacroParser.new(entry).parse
        end

        # 2) assemble the AST children
        children = []
        children.concat macros if macros.any?

        # 3) build the parsed source
        source = macros.map(&:source).join(Sigils::PIPE_OPERATOR)

        # 4) build the AST
        AST::Node.new(:pipeline, children, urtext: urtext, source: source)
      end
    end
  end
end
