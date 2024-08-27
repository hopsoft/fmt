# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses embeds from a string and builds an AST (Abstract Syntax Tree)
  class EmbedParser < Parser
    # @rbs return: Regexp -- detects the start of an embed
    START = Regexp.new("(?=%s)" % Regexp.escape(Sigils::EMBED_PREFIX)).freeze

    # @rbs return: Regexp -- detects the end of an embed
    FINISH = Regexp.new("(?=%{format}[%{name_prefix}]\\w+[%{name_suffix}])?(%{suffix}|[%{name_suffix}])" % {
      format: Sigils::FORMAT_PREFIX,
      name_prefix: Sigils::NAME_PREFIXES.join,
      name_suffix: Sigils::NAME_SUFFIXES.join,
      suffix: Regexp.escape(Sigils::EMBED_SUFFIX)
    }).freeze

    # @rbs return: Regexp -- detects a named formatter
    NAME = Regexp.new("%{format}[%{prefix}]\\w+[%{suffix}]" % {
      format: Sigils::FORMAT_PREFIX,
      prefix: Sigils::NAME_PREFIXES.join,
      suffix: Sigils::NAME_SUFFIXES.join
    }).freeze

    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs scanner: StringScanner?
    def initialize(urtext = "", scanner: nil)
      @urtext = urtext.to_s
      @scanner = scanner || StringScanner.new(@urtext)
    end

    attr_reader :urtext  # :: String -- original source code
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
      {embed: extract_embed}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs embed: String -- extracted embed
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(embed:)
      TemplateParser.new(embed, scanner: scanner).parse
    end

    private

    # Extracts the next embed string
    # @rbs return: String?
    def extract_embed
      return "" unless match?

      scanner.skip_until(START)
      value = scanner.scan_until(FINISH)

      while scanner.matched? && unbalanced?(value)
        match = scanner.scan_until(FINISH)
        value = "#{value}#{match}" if scanner.matched?
        break if scanner.eos?
      end

      value
    end

    # Indicates if the urtext contains an embed
    # @rbs return: bool
    def match?
      urtext.include?(Sigils::EMBED_PREFIX) && urtext.include?(Sigils::EMBED_SUFFIX)
    end

    # Indicates if the embed string is balanced
    # @rbs embed: String
    # @rbs return: bool
    def balanced?(embed)
      nameless = embed.gsub(NAME, "")
      nameless.count(Sigils::EMBED_PREFIX) == nameless.count(Sigils::EMBED_SUFFIX)
    end

    # Indicates if the embed string is unbalanced
    # @rbs embed: String
    # @rbs return: bool
    def unbalanced?(embed)
      !balanced?(embed)
    end
  end
end
