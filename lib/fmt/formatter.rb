# frozen_string_literal: true

require "singleton"
require_relative "filters"
require_relative "scanners"
require_relative "transformer"

module Fmt
  class Formatter
    include Singleton

    attr_reader :filters

    def format(string, **locals)
      result = string.to_s
      transformer = next_transformer(result)

      while transformer
        result = transformer.transform(result, **locals)
        transformer = next_transformer(result)
      end

      result
    end

    private

    def initialize
      super
      @filters = Fmt::Filters.new
    end

    def next_transformer(string)
      scanner = Fmt::KeyScanner.new(string)
      key = scanner.scan
      return nil unless key

      scanner = Fmt::FilterScanner.new(scanner.rest, filters: filters)
      scanner.scan

      Fmt::Transformer.new(key.to_sym, filters: scanner.members, placeholder: "%{#{key}}#{scanner.value}".strip)
    end
  end
end
