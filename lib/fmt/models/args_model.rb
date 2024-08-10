# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgsModel < Model
    # Constructor
    # @rbs tokens: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens
    # @rbs return: Fmt::ArgsModel
    def initialize(*tokens)
      @processor = ArgsProcessor.new
      super
    end

    def_delegators :processor, :args, :kwargs

    # AST representation of the model
    # @rbs return: AST::Node
    def ast
      @ast ||= ast_node(:args, tokens_ast, source: source)
    end
  end
end
