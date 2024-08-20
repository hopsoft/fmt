# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateParser < Parser
    FORMAT_PREFIX = Regexp.new(Regexp.escape(Sigils::FORMAT_PREFIX)).freeze # :: Regexp -- template prefix

    # @rbs return: Regexp -- macros
    MACROS = Regexp.new("(?=\\s|%%|%{embed_prefix}|$)(.*[%{args_suffix}])*" % {
      embed_prefix: Regexp.escape(Sigils::EMBED_PREFIX),
      args_suffix: Sigils::ARGS_SUFFIX
    }).freeze

    # Constructor
    # @rbs scanner: StringScanner -- scanner to use
    def initialize(urtext = "")
      @urtext = urtext.to_s
      @scanner = StringScanner.new(urtext)
    end

    attr_reader :urtext # :: String -- original source code

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
      return {embeds: nil, pipeline: nil} unless scanner.matched?

      {
        embeds: embeds,
        pipeline: scanner.scan_until(MACROS)
      }
    end

    def transform(embeds:, pipeline:)
      children = []
      children << PipelineParser.new(pipeline).parse if pipeline&.size&.positive?
      children << embeds unless embeds.empty?

      source = begin
        list = [Sigils::FORMAT_PREFIX]
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
