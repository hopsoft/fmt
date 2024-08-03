# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestCustomTemplates < UnitTest
    def test_basic
      source = "%cyan"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: "cyan"
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "cyan", arguments: []
      end
    end

    def test_basic_with_key
      source = "%{value}red|>bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "red|>bold|>underline"
        assert_equal 3, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: []
        assert_macro t.macros[1], source: "bold", arguments: []
        assert_macro t.macros[2], source: "underline", arguments: []
      end
    end

    # source = "%{value}|>cyan|>truncate(20, separator: '...')|>bold {{%{nate}|>blue|>truncate(20, separator: '...')}}"
  end
end
