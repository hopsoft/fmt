# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses embeds from a string and builds an AST (Abstract Syntax Tree)
  class EmbedParser < Parser
    START = Regexp.new("(?=%s)" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze # :: Regexp
    FINISH = Regexp.new(Regexp.escape(Sigils::EMBED_SUFFIX)).freeze           # :: Regexp

    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs scanner: StringScanner?
    def initialize(urtext = "", scanner: nil)
      @urtext = urtext.to_s
      @scanner = scanner || StringScanner.new(@urtext)
    end

    attr_reader :urtext # :: String -- original source code
    attr_reader :scanner # :: StringScanner

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      scanner.skip_until(START)
      embed = scanner.scan_until(FINISH)

      while scanner.matched? && unbalanced?(embed)
        match = scanner.scan_until(FINISH)
        embed = "#{embed}#{match}" if scanner.matched?
      end

      {embed: embed.to_s.strip}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs embed: String -- extracted embed
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(embed:)
      template_urtext = embed.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)
      TemplateParser.new(template_urtext, scanner: scanner).parse
    end

    private

    # Indicates if the embed string is balanced
    # @rbs embed: String
    # @rbs return: bool
    def balanced?(embed)
      embed.scan(START).size == embed.scan(FINISH).size
    end

    # Indicates if the embed string is unbalanced
    # @rbs embed: String
    # @rbs return: bool
    def unbalanced?(embed)
      !balanced?(embed)
    end
  end
end
