# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroAST < AST::Node
    # Stub
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :macro
    end

    # Constructor
    # @rbs proc_ast: Fmt::ProcAST
    # @rbs arguments_ast: Fmt::ArgumentsAST
    # @rbs return: Fmt::TokenAST
    def initialize(proc_ast, arguments_ast)
      @source = "#{proc_ast.name}#{arguments_ast.source}"
      super(:macro, [proc_ast, arguments_ast])
    end

    attr_reader :source # :: String -- source code
  end
end
