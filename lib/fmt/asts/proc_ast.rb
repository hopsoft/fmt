# frozen_string_literal: true

# rbs_inline: enabled

require "ast"
require_relative "token_ast"

module Fmt
  class ProcAST < AST::Node
    # AST stub
    # @rbs return: AST::Node
    def self.ast
      AST::Node.new :proc
    end

    # Constructor
    # @rbs key: Symbol -- registry key for the Proc
    # @rbs filename: String -- full path to the file where the Proc is defined
    # @rbs lineno: Integer -- line number where the Proc begins in filename
    # @rbs return: Fmt::Model
    def initialize(key, filename:, lineno:)
      @key = key
      @filename = filename
      @lineno = lineno

      super(
        :proc,
        [AST::Node.new(:key, [key])],
        filename: filename,
        lineno: lineno
      )
    end

    attr_reader :key      # :: Symbol
    attr_reader :filename # :: String
    attr_reader :lineno   # :: Integer
  end
end
