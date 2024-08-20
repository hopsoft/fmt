# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class EmbedParser < Parser
    PREFIX = Regexp.new("(?=(%s))" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp
    SUFFIX = Regexp.new("(%s)" % Regexp.escape(Sigils::EMBED_SUFFIX)).freeze     # :: Regexp

    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs depth: Integer -- nesting depth
    def initialize(urtext = "", depth: 0)
      @urtext = urtext.to_s
      @scanner = StringScanner.new(urtext)
      @depth = depth
    end

    attr_reader :urtext # :: String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: EmbedNode --
    def parse
      cache urtext do
        super
        # embeds = []
        # index = 0
        # embed = next_embed(depth: depth, index: index)

        # while embed
        #   embeds << embed
        #   embed = next_embed(depth: depth, index: index += 1)
        # end

        # Node.new(:embeds, embeds, urtext: urtext, source: urtext)
      end
    end

    protected

    attr_reader :scanner # :: StringScanner -- scanner to use
    attr_reader :depth   # :: Integer -- nesting depth

    def extract
      return {embeds: []} unless scanner.rest.match?(PREFIX)
      return {embeds: []} unless scanner.rest.match?(SUFFIX)

      extract_embed = proc do
        scanner.skip_until(PREFIX)
        text = scanner.scan_until(SUFFIX)
        while scanner.matched? && unbalanced?(text)
          match = scanner.scan_until(SUFFIX)
          text = "#{text}#{match}" if scanner.matched?
        end
        (scanner.matched? && balanced?(text)) ? text : nil
      end

      embeds = []
      embed = extract_embed.call
      while embed
        embeds << embed
        embed = extract_embed.call
      end

      {embeds: embeds}
    end

    def transform(embeds:)
      children = embeds.each_with_object([]).with_index do |(embed, memo), index|
        name = "embed_#{depth}_#{index}"
        placeholder = "#{Sigils::EMBED_PREFIX}#{name}#{Sigils::EMBED_SUFFIX}"
        template_urtext = embed.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)
        nested_embeds = EmbedParser.new(template_urtext, depth: depth + 1).parse

        nodes = []
        nodes << Node.new(:name, [name])
        nodes << Node.new(:placeholder, [placeholder])
        nodes << nested_embeds unless nested_embeds.empty?

        memo << Node.new(:embed, nodes, urtext: embed, source: embed, template_urtext: template_urtext)
      end

      source = urtext.dup
      children.each do |child|
        original = "#{Sigils::EMBED_PREFIX}#{child.template_urtext}#{Sigils::EMBED_SUFFIX}"
        source.gsub! original, child.dig(:placeholder, String)
      end

      Node.new(:embeds, children, urtext: urtext, source: source)
    end

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
  end
end
