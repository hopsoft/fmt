# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # @see https://github.com/whitequark/ast
  # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
  class ProcProcessor
    include AST::Processor::Mixin

    attr_reader :key      # :: Symbol  -- key for the Proc in the registry
    attr_reader :filename # :: String  -- source code file where the Proc is defined
    attr_reader :lineno   # :: Integer -- line number where the Proc is defined
    attr_reader :tokens   # :: String  -- Source code tokens
    attr_reader :source   # :: String  -- Proc source code

    def block
      @block ||= Fmt.registry[key]
    end

    def on_procedure(node)
      process_all node.children
    end

    def on_key(node)
      @key = node.children.first
    end

    def on_filename(node)
      @filename = node.children.first
    end

    def on_lineno(node)
      @lineno = node.children.first
    end

    def on_tokens(node)
      @tokens = node.children
      @source = node.children.join
    end
  end
end
