# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcModel < Model
    # Constructor
    # @rbs tokens: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens
    # @rbs key: Symbol -- registry key for the Proc
    # @rbs filename: String -- full path to the file where the Proc is defined
    # @rbs lineno: Integer -- line number where the Proc begins in filename
    # @rbs return: Fmt::ProcModel
    def initialize(*tokens, key:, filename:, lineno:)
      @processor = ProcProcessor.new
      @key = key
      @filename = filename
      @lineno = lineno
      super(*tokens)
    end

    def_delegators :processor, :key, :block

    attr_reader :key      # :: Symbol
    attr_reader :filename # :: String
    attr_reader :lineno   # :: Integer

    # AST representation of the model
    # @rbs return: AST::Node
    def ast
      @ast ||= ast_node(:proc, ast_node(:key, key),
        filename: filename,
        lineno: lineno,
        source: source,
        tokens: tokens_ast)
    end
  end
end
