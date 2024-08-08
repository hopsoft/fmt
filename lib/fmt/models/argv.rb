# frozen_string_literal: true

# rbs_inline: enabled

require_relative "model"

module Fmt
  # Represents arguments used when invoking a Macro, both positional and keyword
  class Argv < Model
    def initialize(source, *args, **kwargs)
      @source = source
      @positional = args
      @keyword = kwargs
    end

    attr_reader :source     # : String -- source code
    attr_reader :positional # : Array[Object] -- positional arguments
    attr_reader :keyword    # : Hash[Symbol, Object] -- keyword arguments

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        positional: positional,
        keyword: keyword
      }
    end
  end
end
