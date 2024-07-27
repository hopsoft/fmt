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
      raise Fmt::Error, "Missing key :#{key} in #{locals.inspect}" unless locals.key?(key)

      replacement = locals[key]

      filters.each do |filter|
        if filter.string?
          begin
            replacement = sprintf("%#{filter.value}", replacement)
          rescue => error
            message = <<~MSG
              Invalid filter!
              #{filter.inspect}
              Verify it's either a valid native filter or is registered with Fmt.
              Example: Fmt.add_filter(:#{filter.name}, &block)
              #{error.message}
            MSG
            raise Fmt::Error, message
          end
        elsif filter.proc?
          begin
            replacement = filter.value.call(replacement)
          rescue => error
            message = <<~MSG
              Error in filter!
              #{filter.inspect}
              #{error.message}
            MSG
            raise Fmt::Error, message
          end
        end
      end

      result = string.sub placeholder, replacement
      defined?(Rainbow) ? Rainbow(result) : result
    end
  end
end
