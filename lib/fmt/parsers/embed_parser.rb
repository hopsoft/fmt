# frozen_string_literal: true

# rbs_inline: enabled

require "strscan"
require_relative "parser"
require_relative "../models/embed"

module Fmt
  class EmbedParser < Parser
    HEAD = Pattern.build("(?=%s)", Pattern.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp

    EMBED = Pattern.build(
      "(%{embed_prefix}%{prefix}[^\\s%{embed_prefix}]+\\s*(%{embed_prefix}.*%{embed_suffix})*\\s*%{embed_suffix})", {
        prefix: Pattern.escape(Sigils::PREFIX),
        embed_prefix: Pattern.escape(Sigils::EMBED_PREFIX),
        embed_suffix: Pattern.escape(Sigils::EMBED_SUFFIX)
      }
    ).freeze # :: Regexp

    protected

    def next_embed(scanner, index:)
      scanner.skip_until(HEAD)
      return unless scanner.matched?

      source = scanner.scan(EMBED)
      return unless scanner.matched?

      Embed.new source, index: index
    end

    def perform
      @value = []

      index = 0
      scanner = StringScanner.new(source)
      embed = next_embed(scanner, index: index)

      while embed
        value << embed
        embed = next_embed(scanner, index: index += 1)
      end
    end
  end
end
