# frozen_string_literal: true

# rbs_inline: enabled

require_relative "macro"
require_relative "model"

module Fmt
  class Template < Model
    # Constructor
    # @rbs source:    String -- source code
    # @rbs key:       Symbol -- template key
    # @rbs pipeline:  String -- pipeline source code
    # @rbs templates: Hash[Symbol, Fmt::Template] -- nested templates
    # @rbs return:    Fmt::Template
    def initialize(source, key:, pipeline:, templates: {})
      @source = source
      @key = key&.to_sym
      @pipeline = pipeline.to_s
      @macros ||= begin
        list = pipeline&.split(Sigils.pipe_operator)&.reject(&:empty?) || []
        list&.map { |value| Fmt::Macro.new value }
      end
      @templates = templates # nested templates
    end

    attr_reader :source    # : String -- source code ➜ %{value}red|bold
    attr_reader :key       # : Symbol? -- template key ➜ :value
    attr_reader :pipeline  # : String -- pipeline source code ➜ s|>red|>bold
    attr_reader :macros    # : Array[Fmt::Macro] -- macros
    attr_reader :templates # : Hash[Symbol, Array[Fmt::Template]] -- nested templates

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        source: source,
        key: key,
        pipeline: pipeline,
        macros: macros.map(&:to_h),
        templates: templates.each_with_object({}) do |(key, list), memo|
          memo[key] = list.map(&:to_h)
        end
      }
    end
  end
end
