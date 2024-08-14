# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateParser < Parser
    FORMAT_SPECIFIER = Regexp.new("[%s]" % Sigils::FORMAT_SPECIFIERS.map { |s| Regexp.escape(s) }.join).freeze # :: Regexp -- format specifier
    TEMPLATE_PREFIX = Regexp.new(Regexp.escape(Sigils::TEMPLATE_PREFIX)).freeze   # :: Regexp -- template prefix
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
    # @rbs return: Fmt::ArgsParser
    def initialize(scanner)
      @scanner = scanner
      @source = scanner.rest.dup
    end

    attr_reader :scanner # : StringScanner -- scanner to use
    attr_reader :source # : String -- source code

    protected

    # Parses the source
    # @rbs return: AST::Node[Fmt::TemplateAST]
    def perform
      @ast ||= cache(source) do
        source = scanner.rest

        # # 1) extract embedded templates
        embeds = [] # TODO: revisit embeds
        # embeds = EmbedParser.new(source).parse
        # nested_templates = embeds.each_with_object({}) do |embed, templates|
        #   source = source.sub(embed.source, embed.placeholder)
        #   templates[embed.key] = TemplateParser.new(embed.template_source).parse
        # end

        # 2) update the source string as it may have been modified based on embeds
        scanner.string = source

        # 3) advance to the template prefix
        #    @example "%{name}cyan" -- template prefix == "%"
        scanner.skip_until TEMPLATE_PREFIX
        return unless scanner.matched?

        # 4) extract native Ruby format specifier
        specifier = scanner.scan_until(FORMAT_SPECIFIER) if scanner.match?(FORMAT_SPECIFIER)

        # 6) extract template key if one exists
        #    @example "%{name}cyan" -- key == "name"
        scanner.skip_until KEY_PREFIX
        key = scanner.scan(KEY_VALUE) if scanner.matched?
        scanner.skip_until KEY_SUFFIX if scanner.matched?

        # 6) extract the pipeline AST
        #    @example "%{name}cyan|>bold|>..."
        pipeline = scanner.scan_until(MACROS)
        pipeline_ast = PipelineParser.new(pipeline).parse if scanner.matched?

        # 7) build the template AST
        TemplateAST.new(specifier, key, pipeline_ast, *embeds)
      end
    end
  end
end
