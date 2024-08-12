# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TokenAST < AST::Node
    # Stub
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :token
    end

    # Constructor
    # @rbs token: Fmt::TokenModel -- Ripper token
    # @rbs return: Fmt::TokenAST
    def initialize(token)
      @source = token.value
      super(token.type, [token.value])
    end

    attr_reader :source # :: String -- source code
  end
end
