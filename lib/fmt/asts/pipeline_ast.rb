# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineAST < AST::Node
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :pipeline
    end

    # Constructor
    # @rbs macro_asts: Array[Fmt::MacroAST]
    # @rbs return: Fmt::PipelineAST
    def initialize(*macro_asts)
      @source = macro_asts.map(&:source).join(Sigils::PIPE_OPERATOR)
      super(:pipeline, [AST::Node.new(:macros, macro_asts)])
    end

    attr_reader :source # :: String -- source code
  end
end
