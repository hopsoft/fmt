# frozen_string_literal: true

# rbs_inline: enabled

require "ast"
require_relative "../processors/proc_processor"

module Fmt
  class ProcModel
    def initialize(ast)
      processor = ProcProcessor.new
      processor.process ast

      @key = processor.key
      @block = processor.block
      @filename = ast.filename
      @lineno = ast.lineno
    end

    attr_reader :key      # :: Symbol?
    attr_reader :block    # :: Proc?
    attr_reader :filename # :: String?
    attr_reader :lineno   # :: Integer?
  end
end
