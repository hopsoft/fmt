# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class RootAST < AST::Node
    TYPE = :root

    # Constructor
    # @rbs template_asts: Array[Fmt::TemplateAST]
    # @rbs return: Fmt::RootAST
    def initialize(source, *template_asts)
      @source = source
      super(TYPE, template_asts)
    end

    attr_reader :source # :: String -- source code
  end
end
