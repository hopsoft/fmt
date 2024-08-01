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
    def initialize(placeholder, string:)
      @key = :"embed_#{SecureRandom.alphanumeric(16)}"
      @placeholder = placeholder
      @string = string
    end

    attr_reader :key # : Symbol -- unique key that identifies the embed
    attr_reader :placeholder # : String -- placeholder
    attr_reader :string # : String -- string that contains embed
    attr_accessor :template # : Fmt::Template -- template for this embed

    def template_string
      placeholder.delete_prefix(HEAD).delete_suffix(TAIL)
    end

    def format(locals: {})
      result = template.format(locals: locals)

      return string.sub(placeholder, result) unless templated?

      locals[key] = result
      string.sub placeholder, key.to_s
    end

    # Indicates if the embed is wrapped in a template
    #
    # @example
    # %{{{%{embed_value}red|bold}}}underline
    #
    # @rbs return: bool
    def templated?
      string.match?(/%{\s*#{placeholder}\s*}/)
    end
  end
end
