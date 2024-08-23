# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses embeds from a string and builds an AST (Abstract Syntax Tree)
  class EmbedsParser < Parser
    PREFIX = Regexp.new("(?=%s)" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp
    SUFFIX = Regexp.new(Regexp.escape(Sigils::EMBED_SUFFIX)).freeze            # :: Regexp

    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
      @scanner = StringScanner.new(@urtext)
    end

    attr_reader :urtext # :: String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    attr_reader :scanner # :: StringScanner

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      {embeds: extract_embeds}
    end

    # Extracts all embed strings
    # @rbs return: Array[String]
    def extract_embeds
      embeds = []
      embed = extract_embed

      while embed
        embeds << embed
        embed = extract_embed
      end

      embeds
    end

    # Extracts the next embed string
    # @rbs return: String?
    def extract_embed
      scanner.skip_until(PREFIX)
      text = scanner.scan_until(SUFFIX)

      while scanner.matched? && unbalanced?(text)
        match = scanner.scan_until(SUFFIX)
        text = "#{text}#{match}" if scanner.matched?
      end

      return nil unless scanner.matched? && balanced?(text)
      text
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs embeds: Array[String] -- extracted embeds
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(embeds:)
      children = embeds.each_with_object([]) do |embed, memo|
        template_urtext = embed.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)
        template = TemplateParser.new(template_urtext).parse
        memo << template unless template.empty?
      end

      Node.new(:embeds, children, urtext: urtext, source: urtext)
    end

    # Indicates if the text represents a balanced embed (equal prefixes and suffixes)
    # @rbs embed: String
    # @rbs return: bool
    def balanced?(embed)
      embed.scan(PREFIX).size == embed.scan(SUFFIX).size
    end

    # Indicates if the text represents an unbalanced embed (unequal prefixes and suffixes)
    # @rbs embed: String
    # @rbs return: bool
    def unbalanced?(embed)
      !balanced?(embed)
    end
  end
end
