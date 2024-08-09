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
      placeholder = "%{prefix}%{key_prefix}%{key}%{key_suffix}" % {
        prefix: Sigils::PREFIX,
        key_prefix: Sigils::KEY_PREFIXES[0],
        key: key,
        key_suffix: Sigils::KEY_SUFFIXES[0]
      }

      super(
        :argv,
        [
          AST::Node.new(:key, :"fmt_embed_#{index}"),
          AST::Node.new(:placeholder, placeholder)
        ],
        source: source,
        template_source: source
          .delete_prefix(Sigils::EMBED_PREFIX)
          .delete_suffix(Sigils::EMBED_SUFFIX)
      )
    end

    attr_reader :source          # : String -- source code
    attr_reader :template_source # : String -- template source code ➜ %{value}red|bold
  end
end
