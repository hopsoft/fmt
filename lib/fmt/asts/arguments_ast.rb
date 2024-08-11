# frozen_string_literal: true

# rbs_inline: enabled

require "ast"
require_relative "token_ast"

module Fmt
  class ArgumentsAST < AST::Node
    # AST stub
    # @rbs return: AST::Node
    def self.ast
      AST::Node.new :arguments
    end

    # Constructor
    # @rbs tokens: Array[Fmt::TokenModel] -- Ripper tokens
    # @rbs return: Fmt::Model
    def initialize(*tokens)
      @tokens = tokens

      super(
        :arguments,
        [AST::Node.new(:tokens, tokens.map { |t| TokenAST.new t })],
        source: tokens.map(&:value).join
      )
    end

    attr_reader :tokens # :: Array[Fmt::TokenModel] -- Ripper tokens
    attr_reader :source # :: String -- source code based on Ripper tokens
  end
end
