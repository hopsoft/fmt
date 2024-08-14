# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class EmbedParser < Parser
    HEAD = Regexp.new("(?=%s)" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp

    # :: Regexp
    EMBED = Regexp.new(
      "(%{embed_prefix}%{prefix}[^\\s%{embed_prefix}]+\\s*(%{embed_prefix}.*%{embed_suffix})*\\s*%{embed_suffix})" % {
        prefix: Regexp.escape(Sigils::TEMPLATE_PREFIX),
        embed_prefix: Regexp.escape(Sigils::EMBED_PREFIX),
        embed_suffix: Regexp.escape(Sigils::EMBED_SUFFIX)
      }
    ).freeze

    protected

    def next_embed(scanner, index:)
      scanner.skip_until(HEAD)
      return unless scanner.matched?

      source = scanner.scan(EMBED)
      return unless scanner.matched?

      Embed.new source, index: index
    end

    def perform
      value = []

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
