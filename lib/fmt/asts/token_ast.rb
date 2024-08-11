# frozen_string_literal: true

# rbs_inline: enabled

require "ast"

module Fmt
  class TokenAST < AST::Node
    # Stub
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :unknown
    end

    # Constructor
    # @rbs token: Fmt::TokenModel -- Ripper token
    # @rbs return: Fmt::TokenAST
    def initialize(token)
      super(token.type, [token.value])
    end
  end
end
