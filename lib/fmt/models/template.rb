# frozen_string_literal: true

# rbs_inline: enabled

require_relative "macro"

module Fmt
  class Template
    def initialize(source, key:, pipeline:)
      @source = source
      @key = key&.to_sym
      @pipeline = pipeline.to_s
      @macros ||= begin
        list = pipeline&.split(Sigils.pipe_operator)&.reject(&:empty?) || []
        list&.map { |value| Fmt::Macro.new value }
      end
      @embeds = []
    end

    attr_reader :source, :key, :pipeline, :macros, :embeds

    def to_h
      {
        source: source,
        key: key,
        pipeline: pipeline,
        macros: macros.map(&:to_h),
        embeds: embeds.map(&:to_h)
      }
    end

    def ==(other)
      to_h == other&.to_h
    end
  end
end