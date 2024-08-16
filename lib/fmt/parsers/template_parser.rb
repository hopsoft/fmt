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
    def initialize(scanner)
      @scanner = scanner
      @urtext = scanner.rest.dup
    end

    attr_reader :scanner # : StringScanner -- scanner to use
    attr_reader :urtext   # : String -- original source code

    protected

    # Parses the urtext (original source code)
    # @rbs return: AST::Node[TemplateAST]
    def perform
      cache urtext do
        source = scanner.rest

        # # 1) extract embedded templates
        embeds = EmbedParser.new(source).parse
        embeds = nil if embeds.children.none?
        # nested_templates = embeds.each_with_object({}) do |embed, templates|
        # source = source.sub(embed.source, embed.placeholder)
        # templates[embed.key] = TemplateParser.new(embed.template_source).parse
        # end

        # 2) update the source string as it may have been modified based on embeds
        scanner.string = source

        # 3) advance to the template prefix
        #    @example "%{name}cyan" -- template prefix == "%"
        scanner.skip_until FORMAT_PREFIX
        return unless scanner.matched?

        # 4) extract template key if one exists
        #    @example "%{name}cyan" -- key == "name"
        scanner.skip_until KEY_PREFIX
        key = scanner.scan(KEY_VALUE) if scanner.matched?
        scanner.skip_until KEY_SUFFIX if scanner.matched?

        # 5) extract the pipeline AST
        #    @example "%{name}cyan|>bold|>..."
        pipeline = scanner.scan_until(MACROS)
        pipeline = nil if pipeline.empty?

        # 6) assemble the children
        children = []
        children << AST::Node.new(:key, [key]) if key
        children << PipelineParser.new(pipeline).parse if pipeline
        children << embeds if embeds

        # 7) build the parsed source
        sources = children.map do |component|
          case component
          in :key, * then "#{Sigils::KEY_PREFIXES.last}#{key}#{Sigils::KEY_SUFFIXES.last}"
          in :pipeline, * then component.source
          in :embeds, * then ""
            # in [EmbedAST] then component.map(&:source).join
          end
        end
        source = "#{Sigils::FORMAT_PREFIX}#{sources.join}"

        # 8) build the template AST
        TemplateAST.new(*children, urtext: urtext, source: source)
      end
    end
  end
end
