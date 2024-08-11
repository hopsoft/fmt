# frozen_string_literal: true

# rbs_inline: enabled

require "ast"

module Fmt
  class MacroAST < AST::Node
    # Stub
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :macro
    end

    # Constructor
    # @rbs return: Fmt::TokenAST
    def initialize(proc_ast, arguments_ast)
      super(:macro, [proc_ast, arguments_ast])
    end
  end
end
