# frozen_string_literal: true

require "singleton"
require_relative "filter_groups/filter_group"
require_relative "filter_groups/rainbow_filter_group"
require_relative "filter_groups/native_filter_group"
require_relative "scanners"
require_relative "transformer"

module Fmt
  class Formatter
    include Singleton

    attr_reader :filters

    def add_rainbow_filters
      filters.merge! Fmt::RainbowFilterGroup.new.to_h
    end

    def add_filter(...)
      filters.add(...)
    end

    def format(string, **locals)
      result = string.to_s
      transformer = next_transformer(result)

      while transformer
        result = transformer.transform_embeds(result, **locals) # 1) transform embeds (i.e. nested templates)
        result = transformer.transform(result, **locals) # ...... 2) transform
        transformer = next_transformer(result)
      end

      result
    end

    private

    def initialize
      super
      @filters = Fmt::FilterGroup.new.merge!(Fmt::NativeFilterGroup.new)
    end

    def next_transformer(string)
      embed_scanner = Fmt::EmbedScanner.new(string)
      embed_scanner.scan

      key_scanner = Fmt::KeyScanner.new(string)
      key = key_scanner.scan
      return nil unless key

      filter_scanner = Fmt::FilterScanner.new(key_scanner.rest, registered_filters: filters)
      filter_string = filter_scanner.scan

      Fmt::Transformer.new key.to_sym,
        embeds: embed_scanner.embeds,
        filters: filter_scanner.filters,
        placeholder: "%{#{key}}#{filter_string}".strip
    end
  end
end
