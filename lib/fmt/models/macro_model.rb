# frozen_string_literal: true

# rbs_inline: enabled

require "forwardable"
require_relative "../processors/macro_processor"

module Fmt
  class MacroModel
    extend Forwardable

    def initialize(ast)
      processor = MacroProcessor.new
      processor.process ast

      @proc_model = processor.proc_model
      @arguments_model = processor.arguments_model
    end

    attr_reader :proc_model # :: Fmt::ProcModel
    attr_reader :arguments_model # :: Fmt::ArgsModel

    def_delegators :arguments_model, :args, :kwargs
    def_delegators :proc_model, :name, :block, :filename, :lineno
  end
end
