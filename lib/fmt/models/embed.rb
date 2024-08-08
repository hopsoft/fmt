# frozen_string_literal: true

# rbs_inline: enabled

require_relative "model"

module Fmt
  # Represents an embedded template, but not the template itself
  class Embed < Model
    # Constructor
    # @rbs source: String -- source code
    # @rbs index:  Symbol -- ordinal index
    # @rbs return: Fmt::Embed
    def initialize(source, index:)
      @key = "fmt_embed_#{index}"
      @source = source

      @template_source = source
        .delete_prefix(Sigils::EMBED_PREFIX)
        .delete_suffix(Sigils::EMBED_SUFFIX)

      @placeholder = "%{prefix}%{key_prefix}%{key}%{key_suffix}" % {
        prefix: Sigils::PREFIX,
        key_prefix: Sigils::KEY_PREFIXES[0],
        key: key,
        key_suffix: Sigils::KEY_SUFFIXES[0]
      }
    end

    attr_reader :key             # : Symbol -- embed key ➜ :fmt_0
    attr_reader :source          # : String -- source code
    attr_reader :template_source # : String -- template source code ➜ %{value}red|bold
    attr_reader :placeholder     # : String -- placeholder ➜ %{fmt_0}

    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        key: key,
        source: source,
        template_source: template_source,
        placeholder: placeholder
      }
    end
  end
end
