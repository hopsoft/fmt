# frozen_string_literal: true

require "singleton"
require_relative "filters"
require_relative "transformer"

module Fmt
  class Formatter
    include Singleton

    OPEN = /%\{/
    CLOSE = /\}/
    KEY = /\w+(?=\})/
    # FILTERS = /\A[^\s]+(?=%|\s|$)/
    FILTERS = /([^\s%])+/

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
      scanner = StringScanner.new(string)

      # 1. advance to the opening delimiter
      scanner.skip_until(OPEN)

      # 2. extract the key to be transformed
      key = scanner.scan(KEY)

      # 3. advance to the closing delimiter
      scanner.skip_until(CLOSE) if key

      # 4. scan for the filters
      filter_string = scanner.scan(FILTERS) || "" # if key

      return nil if key.nil? # || filter_string.nil?

      mapped_filters = filter_string.split(Fmt::Filters::DELIMITER).map do |name|
        filters.fetch name.to_sym, Fmt::Filter.new(name, name)
      end

      Fmt::Transformer.new(key.to_sym, *mapped_filters, placeholder: "%{#{key}}#{filter_string}".strip)
    end
  end
end
