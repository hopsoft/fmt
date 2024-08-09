# frozen_string_literal: true

# rbs_inline: enabled

require "pathname"
require_relative "model"
require_relative "../parsers/argument_parser"

module Fmt
  # Single discrete operation used to format a value
  # @note Pipelines are comprised of N macros
  # @rbs source: String -- source code
  class Macro < Model
    def initialize(source)
      @source = source
      @block = Fmt.registry.fetch(source, safe: false) { |*args| sprintf("%#{self}", *args) }
      @argv = Fmt::ArgumentParser.new(source).parse
    end

    attr_reader :source # : String -- source code
    attr_reader :block  # : Proc -- format method
    attr_reader :argv   # : Array[Object] -- arguments to pass the block

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        block: {
          path: block_path,
          line: block.source_location.last,
          arity: block.arity,
          parameters: block.parameters
        },
        argv: argv.to_h
      }
    end

    private

    def block_path
      root = Pathname.new(__dir__).join("..", "..", "..").expand_path
      location = Pathname.new(block.source_location.first)
      location.relative_path_from(root).to_s
    end
  end
end
