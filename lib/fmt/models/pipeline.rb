# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Pipeline
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin
    include Matchable

    # Constructor
    # @rbs ast: AST::Node
    def initialize(ast)
      @macros = []
      process ast
    end

    attr_reader :urtext # :: String -- original source code
    attr_reader :source # :: String -- source code
    attr_reader :macros # :: Array[Fmt::MacroAST]

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        urtext: urtext,
        source: source,
        macros: macros.map(&:to_h)
      }
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def on_pipeline(node)
      @urtext = node.urtext
      @source = node.source
      process_all node.children
    end

    def on_macro(node)
      @macros << Macro.new(node)
    end
  end
end
