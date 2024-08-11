# frozen_string_literal: true

# rbs_inline: enabled

require "ast"
require_relative "../processors/arguments_processor"

module Fmt
  class ArgumentsModel
    def initialize(ast)
      processor = ArgumentsProcessor.new
      processor.process ast

      @source = ast.source
      @args = processor.args
      @kwargs = processor.kwargs
    end

    attr_reader :source # :: String -- source code based on Ripper tokens
    attr_reader :args   # :: Array[Object] -- positional arguments
    attr_reader :kwargs # :: Hash[Symbol, Object] -- keyword arguments
  end
end
