# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroProcessor
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin

    def initialize
      @proc_ast = ProcAST.stub
      @arguments_ast = ArgumentsAST.stub
    end

    attr_reader :proc_ast      # :: Fmt::ProcAST
    attr_reader :arguments_ast # :: Fmt::ArgumentsAST

    def on_macro(node)
      process_all node.children
    end

    def on_proc(node)
      @proc_ast = node
    end

    def on_arguments(node)
      @arguments_ast = node
    end
  end
end
