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
    # @rbs name: Symbol -- registry key for the Proc
    # @rbs filename: String -- full path to the file where the Proc is defined
    # @rbs lineno: Integer -- line number where the Proc begins in filename
    # @rbs return: Fmt::Model
    def initialize(name, filename:, lineno:)
      @name = name
      @filename = filename
      @lineno = lineno

      super(
        :proc,
        [AST::Node.new(:name, [name])],
        filename: filename,
        lineno: lineno
      )
    end

    attr_reader :name     # :: Symbol
    attr_reader :filename # :: String
    attr_reader :lineno   # :: Integer
  end
end
