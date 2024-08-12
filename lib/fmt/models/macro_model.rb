# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroModel
    extend Forwardable
    include PatternMatchable

    # Constructor
    # @rbs ast: MacroAST
    # @rbs processor: AST::Processor::Mixin
    # @rbs return: Fmt::MacroModel
    def initialize(ast, processor: MacroProcessor.new)
      processor.process ast
      @source = ast.source
      @proc_model = ProcModel.new(processor.proc_ast)
      @arguments_model = ArgumentsModel.new(processor.arguments_ast)
    end

    attr_reader :source          # :: String -- source code
    attr_reader :proc_model      # :: Fmt::ProcModel
    attr_reader :arguments_model # :: Fmt::ArgsModel

    def_delegator :proc_model, :name     # :: Symbol -- method name (key in registry)
    def_delegator :proc_model, :block    # :: Proc
    def_delegator :proc_model, :filename # :: String
    def_delegator :proc_model, :lineno   # :: Integer

    def_delegator :arguments_model, :args   # :: Array[Object] -- positional arguments
    def_delegator :arguments_model, :kwargs # :: Hash[Symbol, Object] -- keyword arguments

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        name: name,
        block: block,
        args: args,
        kwargs: kwargs
      }
    end
  end
end
