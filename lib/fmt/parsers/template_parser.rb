# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateParser < Parser
    PREFIX = Pattern.build(Sigils::PREFIX, escape: true).freeze                     # :: Regexp -- template prefix
    KEY_PREFIX = Pattern.build("(?<!\\s|%%)[%s]", Sigils::KEY_PREFIXES.join).freeze # :: Regexp -- named-template key prefix
    KEY_VALUE = /\w+/                                                               # :: Regexp -- named-template key value
    KEY_SUFFIX = Pattern.build("[%s]", Sigils::KEY_SUFFIXES.join).freeze            # :: Regexp -- named-template key suffix
    MACROS = Pattern.build("(?=\\s|%%|%{embed_prefix}|$)(.*[%{args_suffix}])*", {
      embed_prefix: Pattern.escape(Sigils::EMBED_PREFIX),
      embed_suffix: Pattern.escape(Sigils::EMBED_SUFFIX),
      args_suffix: Sigils::ARGS_SUFFIX
    }).freeze                                                                       # :: Regexp -- macros

    protected

    def next_template(scanner)
      source = scanner.rest

      # 1) extract embedded templates
      embeds = EmbedParser.new(source).parse
      nested_templates = embeds.each_with_object({}) do |embed, templates|
        source = source.sub(embed.source, embed.placeholder)
        templates[embed.key] = TemplateParser.new(embed.template_source).parse
      end

      # 2) update the source string as it may be modified based on embedded templates
      scanner.string = source

      # 3) advance to the template prefix (i.e. %...)
      scanner.skip_until PREFIX
      return unless scanner.matched?

      # 4) extract template key if one exists (i.e. %{name}, %<name>)
      scanner.skip_until KEY_PREFIX
      key = scanner.scan(KEY_VALUE) if scanner.matched?
      scanner.skip_until KEY_SUFFIX if scanner.matched?

      # 5) extract the macro pipeline (i.e. s|>truncate(length: 20, separator: '.')|>red|>...)
      pipeline = scanner.scan_until(MACROS)

      # 6) build the template
      Template.new source, key: key, pipeline: pipeline, templates: nested_templates
    end

    def perform
      @value = cache(source) do
        templates = []

        scanner = StringScanner.new(source)
        template = next_template(scanner)

        while template
          templates << template
          scanner = StringScanner.new(scanner.rest)
          template = next_template(scanner)
        end

        @value = templates
      end
    end
  end
end
