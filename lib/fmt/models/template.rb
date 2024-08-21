# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents a formattable string
  #
  # A Template is comprised of:
  # 1. pipeline :: Pipeline -- series of Macros
  # 2. embeds: Array[Template] -- embedded templates
  #
  # @note Embeds are processed in sequence (inner to outer)
  #
  # @examples
  #   %s
  #   %.10f
  #   %{value}s
  #   %<value>.10f
  #   %{value}
  #   %<value>
  #   %<value>.12f|>p|>truncate(10, '.')
  #   %{value}red|>bold|>underline
  #   %<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue}}}}
  #
  class Template < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @embeds = []
      super
    end

    attr_reader :pipeline # :: Pipeline
    attr_reader :embeds   # :: Array[Template]

    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge pipeline: pipeline.to_h
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

    def on_pipeline(node)
      @pipeline = Pipeline.new(node)
    end

    # @note The embeds node has template children
    #       processing children (re)triggers the on_template handler for each embedded template
    def on_embeds(node)
      process_all node.children
    end
  end
end
