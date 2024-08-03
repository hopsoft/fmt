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
        assert_equal 1, t.specifiers.size
        assert_specifier t.specifiers[0], value: "cyan", arguments: []
      end
    end

    def test_basic_with_key
      source = "%{value}red|>bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "red|>bold|>underline"
        assert_equal 3, t.specifiers.size
        assert_specifier t.specifiers[0], value: "red", arguments: []
        assert_specifier t.specifiers[1], value: "bold", arguments: []
        assert_specifier t.specifiers[2], value: "underline", arguments: []
      end
    end

    # source = "%{value}|>cyan|>truncate(20, separator: '...')|>bold {{%{nate}|>blue|>truncate(20, separator: '...')}}"
  end
end
