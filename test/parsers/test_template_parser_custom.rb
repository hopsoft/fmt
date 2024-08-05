# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestTemplateParserCustom < UnitTest
    def test_basic
      source = "%cyan"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: "cyan", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "cyan", arguments: {args: [], kwargs: {}}
      end
    end

    def test_basic_named
      source = "%{value}blue"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "blue", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
      end
    end

    def test_basic_named_alt
      source = "%<value>blue"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "blue", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
      end
    end

    def test_named_with_pipeline
      source = "%{value}red|>bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "red|>bold|>underline", embeds: []
        assert_equal 3, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "bold", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[2], source: "underline", arguments: {args: [], kwargs: {}}
      end
    end

    def test_named_with_pipeline_alt
      source = "%<value>red|>bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :value, pipeline: "red|>bold|>underline", embeds: []
        assert_equal 3, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "bold", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[2], source: "underline", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples
      source = "Multiple: %red %green %blue"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 3, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %red %green %blue", key: nil, pipeline: "red", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %green %blue", key: nil, pipeline: "green", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "green", arguments: {args: [], kwargs: {}}
      end

      templates[2].tap do |t|
        assert_template t, source: " %blue", key: nil, pipeline: "blue", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_named
      source = "Multiple: %{first}red %{second}green %{third}blue"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 3, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %{first}red %{second}green %{third}blue", key: :first, pipeline: "red", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %{second}green %{third}blue", key: :second, pipeline: "green", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "green", arguments: {args: [], kwargs: {}}
      end

      templates[2].tap do |t|
        assert_template t, source: " %{third}blue", key: :third, pipeline: "blue", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_named_alt
      source = "Multiple: %<first>red %<second>green %<third>blue"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 3, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %<first>red %<second>green %<third>blue", key: :first, pipeline: "red", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %<second>green %<third>blue", key: :second, pipeline: "green", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "green", arguments: {args: [], kwargs: {}}
      end

      templates[2].tap do |t|
        assert_template t, source: " %<third>blue", key: :third, pipeline: "blue", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_mixed
      source = "Multiple: %red %{second}green %<third>blue %bold"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 4, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %red %{second}green %<third>blue %bold", key: nil, pipeline: "red", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %{second}green %<third>blue %bold", key: :second, pipeline: "green", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "green", arguments: {args: [], kwargs: {}}
      end

      templates[2].tap do |t|
        assert_template t, source: " %<third>blue %bold", key: :third, pipeline: "blue", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
      end

      templates[3].tap do |t|
        assert_template t, source: " %bold", key: nil, pipeline: "bold", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "bold", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_mixed_with_pipelines
      source = "Multiple: %red|>bold %{second}green|>faint %<third>blue|>italic|>strike %bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 4, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %red|>bold %{second}green|>faint %<third>blue|>italic|>strike %bold|>underline", key: nil, pipeline: "red|>bold", embeds: []
        assert_equal 2, t.macros.size
        assert_macro t.macros[0], source: "red", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "bold", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %{second}green|>faint %<third>blue|>italic|>strike %bold|>underline", key: :second, pipeline: "green|>faint", embeds: []
        assert_equal 2, t.macros.size
        assert_macro t.macros[0], source: "green", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "faint", arguments: {args: [], kwargs: {}}
      end

      templates[2].tap do |t|
        assert_template t, source: " %<third>blue|>italic|>strike %bold|>underline", key: :third, pipeline: "blue|>italic|>strike", embeds: []
        assert_equal 3, t.macros.size
        assert_macro t.macros[0], source: "blue", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "italic", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[2], source: "strike", arguments: {args: [], kwargs: {}}
      end

      templates[3].tap do |t|
        assert_template t, source: " %bold|>underline", key: nil, pipeline: "bold|>underline", embeds: []
        assert_equal 2, t.macros.size
        assert_macro t.macros[0], source: "bold", arguments: {args: [], kwargs: {}}
        assert_macro t.macros[1], source: "underline", arguments: {args: [], kwargs: {}}
      end
    end
  end
end
