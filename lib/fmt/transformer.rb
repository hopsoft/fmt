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

    def transform_embeds(string, **locals)
      while embeds.any?
        embed = embeds.shift
        string = string.sub(embed.placeholder, embed.format(**locals))
      end
      string
    end

    def transform(string, **locals)
      string = transform_embeds(string, **locals)

      raise Fmt::Error, "Missing key! :#{key} <string=#{string.inspect} locals=#{locals.inspect}>" unless locals.key?(key)

      replacement = locals[key]

      filters.each do |filter|
        if filter.string?
          begin
            replacement = sprintf("%#{filter.value}", replacement)
          rescue
            raise Fmt::Error, <<~MSG
              Invalid filter! #{filter.inspect}
              Verify it has been properly registered. SEE: Fmt.add_filter(:#{filter.name}, &block)
            MSG
          end
        elsif filter.proc?
          begin
            # replacement = filter.value.call(replacement)
            replacement = string.instance_exec(replacement, &filter.value)
          rescue => error
            raise Fmt::Error, <<~MSG
              Error in filter! #{filter.inspect}
              #{error.message}
            MSG
          end
        end
      end

      string.sub placeholder, replacement.to_s
    end
  end
end
