# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateAST < AST::Node
    include Composable

    # Constructor
    # @rbs children: Array[String, Symbol, AST::Node, AST::Node]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @key = children.find { _1 in [:key, *] }
      @pipeline = children.find { _1 in [:pipeline, *] }
      @embeds = children.find { _1 in [:embeds, *] }
      super(:template, children, properties)
    end

    attr_reader :key      # :: Symbol?
    attr_reader :pipeline # :: AST::Node?
    attr_reader :embeds   # :: AST::Node?
  end
end
