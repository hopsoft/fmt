# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsModel
    include PatternMatchable

    # Constructor
    # @rbs ast: ArgumentsAST
    # @rbs processor: AST::Processor::Mixin
    # @rbs return: Fmt::ArgumentsModel
    def initialize(ast, processor: ArgumentsProcessor.new)
      processor.process ast
      @source = ast.source
      @args = processor.args
      @kwargs = processor.kwargs
    end

    attr_reader :source # :: String -- source code
    attr_reader :args   # :: Array[Object] -- positional arguments
    attr_reader :kwargs # :: Hash[Symbol, Object] -- keyword arguments

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        args: args,
        kwargs: kwargs
      }
    end
  end
end
