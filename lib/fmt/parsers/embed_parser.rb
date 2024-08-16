# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class EmbedParser < Parser
    PREFIX = Regexp.new("(?=(%s))" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp
    SUFFIX = Regexp.new("(%s)" % Regexp.escape(Sigils::EMBED_SUFFIX)).freeze # :: Regexp

    # #HEAD = Regexp.new("(?=%s)" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp

    ### :: Regexp
    # #EMBED = Regexp.new(
    ##  "(%{embed_prefix}%{prefix}[^\\s%{embed_prefix}]+\\s*(%{embed_prefix}.*%{embed_suffix})*\\s*%{embed_suffix})" % {
    ##    prefix: Regexp.escape(Sigils::FORMAT_PREFIX),
    ##    embed_prefix: Regexp.escape(Sigils::EMBED_PREFIX),
    ##    embed_suffix: Regexp.escape(Sigils::EMBED_SUFFIX)
    ##  }
    # #).freeze

    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # : String -- original source code

    protected

    def balanced?(text)
      text.scan(PREFIX).size == text.scan(SUFFIX).size
    end

    def unbalanced?(text)
      !balanced?(text)
    end

    def next_embed(scanner, depth:, index:)
      scanner.skip_until(PREFIX)
      return unless scanner.matched?

      text = scanner.scan_until(SUFFIX)
      return unless scanner.matched?

      while scanner.matched? && unbalanced?(text)
        match = scanner.scan_until(SUFFIX)
        text = "#{text}#{match}" if scanner.matched?
      end

      return unless balanced?(text)

      source = text
        .delete_prefix(Sigils::EMBED_PREFIX)
        .delete_suffix(Sigils::EMBED_SUFFIX)

      embeds = EmbedParser.new(source).perform(depth: depth + 1)

      children = []
      children << embeds unless embeds.children.none?

      EmbedAST.new(*children, depth: depth, index: index, urtext: text, source: source)
    end

    def perform(depth: 0)
      cache urtext do
        embeds = []
        index = 0
        scanner = StringScanner.new(urtext)
        embed = next_embed(scanner, depth: depth, index: index)

        while embed
          embeds << embed
          embed = next_embed(scanner, depth: depth, index: index += 1)
        end

        AST::Node.new(:embeds, embeds, urtext: urtext, source: urtext)
      end
    end
  end
end
