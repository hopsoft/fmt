# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestTemplateParserEmbeds < UnitTest
    def test_peers_and_nested
      source = "%<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}} {{%<five>cyan|>bold}}"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end
  end
end
