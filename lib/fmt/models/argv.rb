# frozen_string_literal: true

# rbs_inline: enabled

require_relative "model"

module Fmt
  # Represents arguments used when invoking a Macro, both positional and keyword
  class Argv < Model
    def initialize(source, *args, **kwargs)
      super(
        :argv,
        [
          AST::Node.new(:positional, args),
          AST::Node.new(:keyword, kwargs.to_a)
        ],
        source: source
      )
    end

    attr_reader :source # : String -- source code

    # @rbs return: Array[Object] -- positional arguments
    def positional
      @positional ||= find(:positional) || []
    end

    # @rbs return: Hash[Symbol, Object] -- keyword arguments
    def keyword
      @keyword ||= find(:keyword)&.to_h || {}
    end
  end
end
