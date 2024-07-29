# frozen_string_literal: true

module Fmt
  class Transformer
    def initialize(key, embeds:, filters:, placeholder:)
      @key = key
      @embeds = embeds
      @filters = filters
      @placeholder = placeholder
    end

    attr_reader :key, :embeds, :filters, :placeholder, :proc_filters, :string_filters

    def transform(string, **locals)
      string = transform_embeds(string, **locals)

      raise Fmt::Error, "Missing key! :#{key} <string=#{string.inspect} locals=#{locals.inspect}>" unless locals.key?(key)

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

      result = string.sub(placeholder, replacement)
      defined?(Rainbow) ? Rainbow(result) : result
    end

    private

    def transform_embeds(string, **locals)
      while embeds.any?
        embed = embeds.shift
        string = string.sub(embed.placeholder, embed.format(**locals))
      end
      string
    end
  end
end
