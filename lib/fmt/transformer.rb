# frozen_string_literal: true

module Fmt
  class Transformer
    def initialize(key, *filters, placeholder:)
      @key = key
      @filters = filters
      @placeholder = placeholder
    end

    attr_reader :key, :filters, :placeholder, :proc_filters, :string_filters

    def transform(string, **locals)
      return string if filters.none?

      raise Fmt::Error, "Missing key :#{key} in #{locals.inspect}" unless locals.key?(key)
      replacement = locals[key]

      filters.each do |filter|
        if filter.string?
          begin
            replacement = format("%#{filter.value}", replacement)
          rescue => error
            raise Fmt::Error, "Invalid filter! #{filter.inspect} Check the spelling and verify that it's registered `Fmt.add_filter(:#{filter.name}, &block)`; #{error.message}"
          end
        elsif filter.proc?
          begin
            replacement = filter.value.call(replacement)
          rescue => error
            raise Fmt::Error, "Error in filter! #{filter.inspect} #{error.message}"
          end
        end
      end

      string.sub placeholder, replacement
    end
  end
end
