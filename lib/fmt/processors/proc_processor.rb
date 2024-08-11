# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcProcessor
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin

    attr_reader :name   # :: Symbol -- key for the Proc in the registry
    attr_reader :block # :: Proc -- Proc from the registry

    def on_proc(node)
      process_all node.children
    end

    def on_name(node)
      @name = node.children.first
      @block = Fmt.registry[name]
    end
  end
end
