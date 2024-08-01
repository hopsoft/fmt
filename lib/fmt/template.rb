# frozen_string_literal: true

# rbs_inline: enabled

require_relative "embed"

module Fmt
  class Template
    HEAD = "%{"
    TAIL = "}"

    # Initializes a Fmt::Template instance
    # @rbs key: Symbol -- unique key that identifies the template
    # @rbs filters: Array[Fmt::Filter] -- filters to apply
    # @rbs embeds: Array[Fmt::Embed] -- embeddings
    # @rbs string: String -- string that contains template
    # @rbs return: Fmt::Template
    def initialize(key, *filters, embeds: [], string: "")
      @key = key.to_sym
      @filters = filters
      @embeds = embeds
      @string = string
    end

    attr_reader :key # : Symbol -- unique key that identifies the template
    attr_reader :filters # : Array[Fmt::Filter] -- filters to apply
    attr_reader :embeds # : Array[Fmt::Template] -- embedded templates
    attr_reader :string # : String -- string that contains template

    # The filter string (i.e. red|bold)
    # @rbs return: String
    def filter_string
      filters.map(&:name).join Fmt::Filter::DELIMITER
    end

    # The filter regexp (i.e. /red\|bold/)
    # @rbs return: Regexp
    def filter_regexp
      /#{filters.map(&:name).join "\\#{Fmt::Filter::DELIMITER}"}/
    end

    # The placeholder string (i.e. %{name}red|bold)
    # @rbs return: String
    def placeholder_string
      "#{HEAD}#{key}#{TAIL}#{filter_string}"
    end

    # The template/placeholder regexp (i.e. /%{name}red\|bold/)
    # @rbs return: Regexp
    def placeholder_regexp
      /#{HEAD}#{key}#{TAIL}#{filter_regexp}/
    end

    def format(string, locals: {})
      raise Fmt::Error, "Missing local! :#{key} <string=#{string.inspect} locals=#{locals.inspect}>" unless locals.key?(key)

      string = format_embeds(string, locals: locals) # format embeds first (i.e. nested templates)
      replacement = locals[key]

      filters.each do |filter|
        replacement = filter.apply(replacement, context: string)
      rescue => error
        raise Fmt::Error, "Error in filter! #{filter.inspect}\n#{error.message}"
      end

      string.sub placeholder_regexp, replacement.to_s
    end

    def format_embeds(string, locals: {})
      embeds.each do |embed|
        string = embed.format(locals: locals)
      end
      string
    end
  end
end
