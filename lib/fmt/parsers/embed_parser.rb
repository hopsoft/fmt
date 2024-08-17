# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class EmbedParser < Parser
    PREFIX = Regexp.new("(?=(%s))" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp
    SUFFIX = Regexp.new("(%s)" % Regexp.escape(Sigils::EMBED_SUFFIX)).freeze     # :: Regexp

    def initialize(urtext = "")
      @urtext = urtext.to_s
      @scanner = StringScanner.new(urtext)
    end

    attr_reader :urtext # :: String -- original source code
    attr_reader :scanner # :: StringScanner -- scanner to use

    def parse(depth: 0)
      cache urtext do
        embeds = []
        index = 0
        embed = next_embed(depth: depth, index: index)

        while embed
          embeds << embed
          embed = next_embed(depth: depth, index: index += 1)
        end

        Node.new(:embeds, embeds, urtext: urtext, source: urtext)
      end
    end

    private

    # Indicates if the text represents a balanced embed (equal prefixes and suffixes)
    # @rbs text: String
    # @rbs return: bool
    def balanced?(text)
      text.scan(PREFIX).size == text.scan(SUFFIX).size
    end

    # Indicates if the text represents an unbalanced embed (unequal prefixes and suffixes)
    # @rbs text: String
    # @rbs return: bool
    def unbalanced?(text)
      !balanced?(text)
    end

    # Extracts the embed text (handles nested embeds)
    # @rbs return: String?
    def extract_text
      scanner.skip_until(PREFIX)
      return unless scanner.matched?

      text = scanner.scan_until(SUFFIX)
      return unless scanner.matched?

      while scanner.matched? && unbalanced?(text)
        match = scanner.scan_until(SUFFIX)
        text = "#{text}#{match}" if scanner.matched?
      end

      text = nil unless scanner.matched? && balanced?(text)
      text
    end

    # Builds child AST nodes
    # @rbs key: Symbol -- unique identifier
    # @rbs placeholder: String -- placeholder (replaces the embed in the template)
    # @rbs urtext: String -- original source code
    # @rbs depth: Integer -- nesting depth
    # @rbs return: Array[Node] -- [:key, *], [:placeholder, *], [:embeds, *]?
    def build_children(key, placeholder, urtext, depth:)
      [].tap do |list|
        list << Node.new(:key, [key])
        list << Node.new(:placeholder, [placeholder])

        embeds = EmbedParser.new(urtext).parse(depth: depth)
        list << (embeds.blank? ? nil : embeds)
      end
    end

    # Parses and extracts the next embed
    # @rbs depth: Integer -- nesting depth
    # @rbs index: Integer -- embed index (ordinal position)
    def next_embed(depth:, index:)
      # extract
      text = extract_text
      return unless text

      # parse
      key = :"embed_#{depth}_#{index}"
      placeholder = "#{Sigils::EMBED_PREFIX}#{key}#{Sigils::EMBED_SUFFIX}"
      source = text.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)

      # build
      children = build_children(key, placeholder, source, depth: depth + 1)
      EmbedNode.new(*children, depth: depth, index: index, urtext: text, source: source)
    end
  end
end
