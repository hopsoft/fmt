# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Embed < Model
    attr_reader :key         # : Symbol -- key for embed
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

    # Processes a key AST node
    # @rbs node: Node
    # @rbs return: void
    def on_key(node)
      @key = node.children.first
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
