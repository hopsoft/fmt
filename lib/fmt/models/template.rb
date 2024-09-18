# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents a formattable string
  #
  # A Template is comprised of:
  # 1. embeds: Array[Template] -- embedded templates
  # 2. pipelines :: Array[Pipeline] -- sets of Macros
  #
  # @note Embeds are processed from inner to outer
  #
  class Template < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @embeds = []
      @pipelines = []
      super
    end

    attr_reader :embeds    # : Array[Template]
    attr_reader :pipelines # : Array[Pipeline]

    # The template key (used for embeds)
    # @rbs return: String?
    def key
      ast.properties[:key]
    end

    # Indicates if the template is an embed
    # @rbs return: bool
    def embed?
      !!ast.properties[:embed]
    end

    # Indicates if the template is a wrapped embed
    # @rbs return: bool
    def wrapped?
      return false unless embed?
      !!ast.properties[:wrapped]
    end

    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge embeds: embeds.map(&:to_h), pipelines: pipelines.map(&:to_h)
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def self?(node)
      node == ast
    end

    def on_template(node)
      # handling self
      return process_all(node.children) if self?(node)

      # handling embedded template
      embeds << Template.new(node)
    end

    def on_pipelines(node)
      process_all node.children
    end

    def on_pipeline(node)
      pipelines << Pipeline.new(node)
    end

    # @note The embeds node has template children
    #       processing children (re)triggers the on_template handler for each embedded template
    def on_embeds(node)
      process_all node.children
    end
  end
end
