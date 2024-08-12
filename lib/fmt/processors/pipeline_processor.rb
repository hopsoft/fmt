# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineProcessor
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin

    def initialize
      @macro_asts = []
    end

    attr_reader :macro_asts # :: Array[Fmt::MacroAST]

    def on_pipeline(node)
      process_all node.children
    end

    def on_macros(node)
      process_all node.children
    end

    def on_macro(node)
      @macro_asts << node
    end
  end
end
