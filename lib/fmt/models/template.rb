# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Template < Model
    attr_reader :pipeline # :: Pipeline

    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge pipeline: pipeline.to_h
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    def on_template(node)
      process_all node.children
    end

    def on_pipeline(node)
      @pipeline = Pipeline.new(node)
    end
  end
end
