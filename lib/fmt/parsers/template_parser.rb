# frozen_string_literal: true

# rbs_inline: enabled

require_relative "parser"
require_relative "../models/template"

module Fmt
  class TemplateParser < Parser
    PREFIX = Pattern.build(Sigils::PREFIX, escape: true).freeze # :: Regexp -- template prefix
    KEY_PREFIX = Pattern.build("(?<!\\s|%%)[%s]", Sigils::KEY_PREFIXES.join) # :: Regexp -- named-template key prefix
    KEY_VALUE = /\w+/ # :: Regexp -- named-template key value
    KEY_SUFFIX = Pattern.build("[%s]", Sigils::KEY_SUFFIXES.join) # :: Regexp -- named-template key suffix
    MACROS = Pattern.build("(?=\\s|%%|[%s]|$)(.*[%s])*", Sigils::EMBED_PREFIX[0], Sigils::ARGS_SUFFIX) # :: Regexp -- macros

    protected

    def next_template(source)
      scanner.skip_until PREFIX
      return unless scanner.matched?

      # extract template key
      scanner.skip_until KEY_PREFIX
      key = scanner.scan(KEY_VALUE) if scanner.matched?
      scanner.skip_until KEY_SUFFIX if scanner.matched?

      # extract the macro pipeline
      pipeline = scanner.scan_until(MACROS)

      # TODO: parse embeds

      # build the template
      Template.new source, key: key, pipeline: pipeline
    end

    def perform
      @value = Cache.instance.fetch(source) do
        value = []
        template = next_template(source)

        while template
          value << template
          template = next_template(tail)
        end

        value
      end
    end
  end
end
