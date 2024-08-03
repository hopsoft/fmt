# frozen_string_literal: true

# rbs_inline: enabled

require_relative "parser"
require_relative "../models/template"

module Fmt
  class TemplateParser < Parser
    PREFIX = Pattern.build(Sigils::PREFIX, escape: true).freeze # :: Regexp -- template prefix
    KEY_PREFIX = Pattern.build("[%s]", Sigils::KEY_PREFIXES.join) # :: Regexp -- named-template key prefix
    KEY_VALUE = /\w+/ # :: Regexp -- named-template key value
    KEY_SUFFIX = Pattern.build("[%s]", Sigils::KEY_SUFFIXES.join) # :: Regexp -- named-template key suffix
    MACROS = Pattern.build("(?=\\s*%s|$)", Sigils::EMBED_PREFIX) # :: Regexp -- macros

    # Creates a template parser
    # @rbs source: String -- string being parsed (default: "")
    def initialize(source = "")
      super
      @value = []
    end

    protected

    def next_template
      scanner.skip_until PREFIX
      return nil unless scanner.matched?

      scanner.skip_until KEY_PREFIX
      key = scanner.scan(KEY_VALUE) if scanner.matched?
      scanner.skip_until KEY_SUFFIX if scanner.matched?

      pipeline = scanner.scan_until(MACROS)

      Template.new source, key: key, pipeline: pipeline
    end

    def perform
      return value unless source.include?(Sigils::PREFIX)

      # while (match = next_match)
      # value << match
      # end
      # value

      value << next_template
    end
  end
end
