# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents a series of Macros
  #
  # A Pipeline is comprised of:
  # 1. macros: Array[Macro]
  #
  # @note Pipelines are processed in sequence (left to right)
  #
  class Embed < Model
    attr_reader :placeholder # : String -- placeholder for embed
    attr_reader :template    # : Template

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge placeholder: placeholder, template: template&.to_h
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    # Processes an embed AST node
    # @rbs node: Node
    # @rbs return: void
    def on_embed(node)
      process_all node.children
    end

    # Processes a placeholder AST node
    # @rbs node: Node
    # @rbs return: void
    def on_placeholder(node)
      @placeholder = node.children.first
    end

    # Processes a template AST node
    # @rbs node: Node
    def on_template(node)
      @template = Template.new(node)
    end
  end
end
