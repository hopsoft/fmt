# frozen_string_literal: true

# rbs_inline: enabled

# require_relative "embed"
require_relative "scanners/template_scanner"

module Fmt
  class Template
    HEAD = "%{"
    TAIL = "}"

    def initialize(string)
    end

    ## Initializes a Fmt::Template instance
    ## @rbs key: Symbol -- unique key that identifies the template
    ## @rbs filters: Array[Fmt::Filter] -- filters to apply
    ## @rbs embeds: Array[Fmt::Embed] -- embeddings
    ## @rbs return: Fmt::Template
    # def initialize(key, *filters, embeds: [])
    #  @key = key.to_sym
    #  @filters = filters
    #  @embeds = embeds
    # end

    attr_reader :key # : Symbol -- unique key that identifies the template
    attr_reader :filters # : Array[Fmt::Filter] -- filters to apply
    attr_reader :embeds # : Array[Fmt::Template] -- embedded templates

    # The placeholder ➜ "%{name}red|bold"
    # @rbs return: String
    def placeholder
      "#{HEAD}#{key}#{TAIL}#{filter_placeholder}"
    end

    # Placeholder regexp
    # @rbs return: Regexp
    def placeholder_regexp(placeholder)
      /(?<head>#{HEAD})(?<head_space>\s)#{key}(?<tail_space>\s)(?<tail>#{TAIL})#{filter_regexp}/
    end

    # The filter placeholder (i.e. red|bold)
    # @rbs return: String
    def filter_placeholder
      filters.map(&:name).join Fmt::Filter::DELIMITER
    end

    # The filter regexp (i.e. /red\|bold/)
    # @rbs return: Regexp
    def filter_regexp
      /#{filters.map(&:name).join "\\#{Fmt::Filter::DELIMITER}"}/
    end

    def format(value = placeholder, **locals)
      raise Fmt::Error, "Missing local! :#{key} <value=#{value.inspect} locals=#{locals.inspect}>" unless locals.key?(key)

      value = format_embeds(value, **locals) # format embeds first (i.e. nested templates)
      binding.pry if embeds.any?

      replacement = locals[key]
      replacement = apply_filters(replacement)

      value.to_s.sub placeholder_regexp, replacement.to_s
    end

    def format_embeds(value, **locals)
      return value unless embeds.any?

      embeds.each do |embed|
        replacement = embed.template.format(**locals)
        # todo: detect if embed itself is wrapped in a template
        binding.pry
        value = value.sub(embed.placeholder_regexp, replacement)
      end

      value
    end

    def apply_filters(value)
      filters.each do |filter|
        value = filter.apply(value, context: value)
      rescue => error
        binding.pry
        raise Fmt::Error, "Error in filter! #{filter.inspect}\n#{error.message}"
      end

      value
    end
  end
end
