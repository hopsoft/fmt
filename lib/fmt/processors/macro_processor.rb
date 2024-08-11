# frozen_string_literal: true

# rbs_inline: enabled

require "ast"
require_relative "../models/arguments_model"
require_relative "../models/proc_model"

module Fmt
  class MacroProcessor
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin

    attr_reader :proc_model # :: Fmt::ProcModel
    attr_reader :arguments_model # :: Fmt::ArgumentsModel

    def on_macro(node)
      process_all node.children
    end

    def on_proc(node)
      @proc_model = ProcModel.new(node)
    end

    def on_arguments(node)
      @arguments_model = ArgumentsModel.new(node)
    end
  end
end
