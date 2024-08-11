# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineModel < Model
    # AST stub
    # @rbs return: AST::Node
    def self.ast
      AST::Node.new :proc
    end

    # Constructor
    # @rbs macros: Array[Fmt::MacroModel] -- MacroModels
    # @rbs return: Fmt::MacroModel
    def initialize(*macros)
      @processor = PipelineProcessor.new
      @macros = macros
      super
    end

    attr_reader :macros # :: Array[Fmt::MacroModel]

    # def_delegators :processor, :

    # AST representation of the model
    # @rbs return: AST::Node
    def ast
      # @ast ||= AST::Node.new(:pipeline, ...)
    end

    # Source code string
    # @rbs return: String
    def source
      macros.map(&:source).join Sigils::PIPE_OPERATOR
    end
  end
end
