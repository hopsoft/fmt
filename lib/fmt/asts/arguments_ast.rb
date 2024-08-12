# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsAST < AST::Node
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :arguments
    end

    # Constructor
    # @rbs tokens: Array[Fmt::TokenModel] -- Ripper tokens
    # @rbs return: Fmt::Model
    def initialize(*tokens)
      @tokens = tokens
      @source = tokens.map(&:source).join
      token_asts = tokens.map { |t| TokenAST.new t }
      super(:arguments, [AST::Node.new(:tokens, token_asts)])
    end

    attr_reader :tokens # :: Array[Fmt::TokenModel] -- Ripper tokens
    attr_reader :source # :: String -- source code
  end
end
