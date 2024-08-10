# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgsProcessor < Processor
    def initialize
      @args = []
      @kwargs = {}
    end

    attr_reader :args # :: Array[Object] -- positional arguments
    attr_reader :kwargs # :: Hash[Symbol, Object] -- keyword arguments

    def on_args(node)
      assign_properties from: node
      process_all node.children
    end

    def on_tokens(node)
      process_all node.children
    end

    def on_int(node)
      @args << node.children.first.to_i
    end

    def on_tstring_content(node)
      @args << node.children.first
    end
  end
end
