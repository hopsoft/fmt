# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateParser < Parser
    FORMAT_PREFIX = Regexp.new(Regexp.escape(Sigils::FORMAT_PREFIX)).freeze       # :: Regexp -- template prefix
    KEY_PREFIX = Regexp.new("(?<!\\s|%%)[%s]" % Sigils::KEY_PREFIXES.join).freeze # :: Regexp -- named-template key prefix
    KEY_VALUE = /\w+/                                                             # :: Regexp -- named-template key value
    KEY_SUFFIX = Regexp.new("[%s]" % Sigils::KEY_SUFFIXES.join).freeze            # :: Regexp -- named-template key suffix

    # :: Regexp -- macros
    MACROS = Regexp.new("(?=\\s|%%|%{embed_prefix}|$)(.*[%{args_suffix}])*" % {
      embed_prefix: Regexp.escape(Sigils::EMBED_PREFIX),
      embed_suffix: Regexp.escape(Sigils::EMBED_SUFFIX),
      args_suffix: Sigils::ARGS_SUFFIX
    }).freeze

    # Constructor
    # @rbs scanner: StringScanner -- scanner to use
    def initialize(urtext = "")
      @urtext = urtext.to_s
      @scanner = StringScanner.new(urtext)
    end

    attr_reader :urtext   # :: String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node[TemplateNode]
    def parse
      cache(urtext) do
        @embeds = parse_embeds # pre-builds embeds AST
        super
      end
    end

    protected

    attr_reader :scanner # :: StringScanner -- scanner to use
    attr_reader :embeds  # :: Node?

    def extract
      scanner.scan_until FORMAT_PREFIX
      return {key: nil, pipeline: nil, embeds: nil} unless scanner.matched?

      key = begin
        scanner.skip_until KEY_PREFIX
        key = scanner.scan(KEY_VALUE) if scanner.matched?
        scanner.skip_until KEY_SUFFIX if scanner.matched?
        key
      end

      {
        key: key,
        pipeline: scanner.scan_until(MACROS)
      }
    end

    def transform(key:, pipeline:)
      children = []
      children << Node.new(:key, [key]) if key
      children << PipelineParser.new(pipeline).parse if pipeline
      children << embeds unless embeds.empty?

      source = begin
        list = [Sigils::FORMAT_PREFIX]
        list << "#{Sigils::KEY_PREFIXES[0]}#{key}#{Sigils::KEY_SUFFIXES[0]}" if key
        list << children.find { _1 in [:pipeline, *] }&.source
        list << scanner.rest
        list.join
      end

      Node.new(:template, children, urtext: urtext, source: source)
    end

    # Parses embedded (nested) templates and updates the scanner string
    def parse_embeds
      return if @embeds_parsed
      @embeds_parsed = true

      source = scanner.rest
      EmbedParser.new(source).parse.tap do |embeds|
        embeds.children.each do |embed|
          placeholder = embed.dig(:placeholder, String)
          scanner.string = scanner.rest.sub(embed.urtext, placeholder)
        end
      end
    end
  end
end
