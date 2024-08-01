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

    # The filter string
    #
    # @example
    # red|bold
    #
    # @rbs return: String
    def filter_string
      filters.map(&:name).join Fmt::Filter::DELIMITER
    end

    # The template string
    #
    # @example
    # %{name}red|bold
    #
    # @rbs return: String
    def template_string
      "#{HEAD}#{key}#{TAIL}#{filter_string}"
    end

    # # The template regex
    # # @rbs return: Regexp
    # def regex
    #   f = filters.map(&:name).join("\\#{Fmt::Filter::DELIMITER}")
    #   Regexp.new "\\s*#{HEAD}#{key}#{TAIL}#{f}\\s*"
    # end

    # The template placeholder string
    # @rbs return: String
    def placeholder
      "#{HEAD}#{key}#{TAIL}#{filter_string}"
    end

    def format(string = nil, locals: {})
      string ||= self.string
      raise Fmt::Error, "Missing local! :#{key} <string=#{string.inspect} locals=#{locals.inspect}>" unless locals.key?(key)

      string = format_embeds(string, locals: locals) # format embeds first (i.e. nested templates)
      replacement = locals[key]

      filters.each do |filter|
        replacement = filter.apply(replacement, context: string)
      rescue => error
        raise Fmt::Error, "Error in filter! #{filter.inspect}\n#{error.message}"
      end

      string.sub placeholder, replacement.to_s
    end

    def format_embeds(string, locals: {})
      embeds.each { |embed| string = embed.format(locals: locals) }
      string
    end
  end
end
