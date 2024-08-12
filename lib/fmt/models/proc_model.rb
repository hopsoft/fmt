# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcModel
    include PatternMatchable

    # Constructor
    # @rbs ast: ProcAST
    # @rbs processor: AST::Processor::Mixin
    # @rbs return: Fmt::ProcModel
    def initialize(ast, processor: ProcProcessor.new)
      processor.process ast
      @source = ast.source
      @name = processor.name
      @block = processor.block
    end

    attr_reader :source # :: String -- source code
    attr_reader :name   # :: Symbol -- method name (key in registry)
    attr_reader :block  # :: Proc

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        name: name,
        block: block
      }
    end
  end
end
