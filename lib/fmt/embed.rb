# frozen_string_literal: true

# rbs_inline: enabled

require "securerandom"

module Fmt
  class Embed
    HEAD = "{{"
    TAIL = "}}"

    # Initializes a Fmt::Embed instance
    # @rbs placeholder: String -- placeholder
    # @rbs string: String -- string that contains embed
    # @rbs return: Fmt::Embed
    def initialize(placeholder_string, string:)
      @key = :"embed_#{SecureRandom.alphanumeric(16)}"
      @placeholder_string = placeholder_string
      @string = string
    end

    attr_reader :key # : Symbol -- unique key that identifies the embed
    attr_reader :placeholder_string # : String -- placeholder
    attr_reader :string # : String -- string that contains embed
    attr_accessor :template # : Fmt::Template -- embed template (assign before calling format)

    # The placeholder regexp (i.e. /{{%{name}red\|bold}}/)
    # @rbs return: Regexp
    def placeholder_regexp
      /#{HEAD}\s*#{template.placeholder_regexp}\s*#{TAIL}/
    end

    # The template string (i.e. %{name}red|bold)
    # @rbs return: String
    def template_string
      placeholder_string.delete_prefix(HEAD).delete_suffix(TAIL)
    end

    # Indicates if the embed is wrapped in a template (i.e. %{{{%{name}red|bold}}}underline)
    # @rbs return: bool
    def templated?
      string.match?(/%{\s*#{placeholder_regexp}\s*}/)
    end

    def format(locals: {})
      replacement = template.format(template_string, locals: locals)

      return string.sub(placeholder_regexp, replacement) unless templated?

      locals[key] = replacement
      string.sub placeholder_regexp, key.to_s
    end
  end
end
