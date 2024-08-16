# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class RootAST < AST::Node
    TYPE = :root

    # Constructor
    # @rbs children: Array[AST::Node]
    def initialize(*children, **properties)
      @source = source
      super(TYPE, template_asts)
    end

    attr_reader :source # :: String -- source code
  end
end
