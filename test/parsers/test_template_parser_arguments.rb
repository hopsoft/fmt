# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestCustomTemplates < UnitTest
    # source = "Inspect: %s|>prepend('Prefix: ', 'nate', 1, 1.2, 1_000, 1_000.123, [1,2,3], {key: true}, foo: 'bar')"
    def test_native_with_args
      source = "%s|>ljust(80, '.')"
      templates = Fmt::TemplateParser.new(source).parse

      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: "s|>ljust(80, '.')", embeds: []
        assert_equal 2, t.macros.size
        assert_macro t.macros[0], source: "s", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "ljust(80, '.')", arguments: {args: [80, "."], kwargs: {}}
      end
    end

    def test_native_named_with_args
      source = "%{value}prepend('Prefix: ')"
      templates = Fmt::TemplateParser.new(source).parse

      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "prepend('Prefix: ')", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "prepend('Prefix: ')", arguments: {args: ["Prefix: "], kwargs: {}}
      end
    end

    def test_custom_kwargs_with_args_and_kwargs
      source = "%{value}prepend('Prefix: ')|>truncate(length: 80, separator: '.')"
      templates = Fmt::TemplateParser.new(source).parse

      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "prepend('Prefix: ')|>truncate(length: 80, separator: '.')", embeds: []
        assert_equal 2, t.macros.size
        assert_macro t.macros[0], source: "prepend('Prefix: ')", arguments: {args: ["Prefix: "], kwargs: {}}
        assert_macro t.macros[1], source: "truncate(length: 80, separator: '.')", arguments: {args: [], kwargs: {length: 80, separator: "."}}
      end
    end
  end
end
