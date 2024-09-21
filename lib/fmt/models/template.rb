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

    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge embeds: embeds.map(&:to_h), pipelines: pipelines.map(&:to_h)
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def on_template(node)
      process_all node.children
    end

    def on_embeds(node)
      process_all node.children
    end

    def on_embed(node)
      embeds << Embed.new(node)
    end

    def on_pipelines(node)
      process_all node.children
    end

    def on_pipeline(node)
      pipelines << Pipeline.new(node)
    end
  end
end
