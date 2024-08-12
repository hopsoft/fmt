# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineModel
    include PatternMatchable

    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :pipeline
    end

    # Constructor
    # @rbs ast: MacroAST
    # @rbs processor: AST::Processor::Mixin
    # @rbs return: Fmt::MacroModel
    def initialize(ast, processor: PipelineProcessor.new)
      processor.process ast
      @source = ast.source
      @macros = processor.macro_asts.map do |macro_ast|
        MacroModel.new macro_ast
      end
    end

    attr_reader :macros # :: Array[Fmt::MacroModel]
    attr_reader :source # :: String -- source code

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        macros: macros.map(&:to_h)
      }
    end
  end
end
