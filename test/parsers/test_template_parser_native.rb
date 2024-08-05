# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestTemplateParserNative < UnitTest
    def test_basic
      source = "Inspect: %p"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end
    end

    def test_basic_named
      source = "Inspect: %{obj}p"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :obj, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end
    end

    def test_basic_named_alt
      source = "Inspect: %<obj>p"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :obj, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end
    end

    def test_complex
      source = "Precision: %.10f"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end
    end

    def test_complex_named
      source = "Precision: %{obj}.10f"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :obj, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end
    end

    def test_complex_named_alt
      source = "Precision: %<obj>.10f"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: :obj, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples
      source = "Multiple: %p %.10f"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 2, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %p %.10f", key: nil, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %.10f", key: nil, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_named
      source = "Multiple: %{obj}p %{num}.10f"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 2, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %{obj}p %{num}.10f", key: :obj, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %{num}.10f", key: :num, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_named_alt
      source = "Multiple: %<obj>p %<num>.10f"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 2, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %<obj>p %<num>.10f", key: :obj, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %<num>.10f", key: :num, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end
    end

    def test_multiples_mixed
      source = "Multiple: %s %{obj}p %<num>.10f %p"
      templates = Fmt::TemplateParser.new(source).parse
      assert_equal 4, templates.size

      templates[0].tap do |t|
        assert_template t, source: "Multiple: %s %{obj}p %<num>.10f %p", key: nil, pipeline: "s", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "s", arguments: {args: [], kwargs: {}}
      end

      templates[1].tap do |t|
        assert_template t, source: " %{obj}p %<num>.10f %p", key: :obj, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end

      templates[2].tap do |t|
        assert_template t, source: " %<num>.10f %p", key: :num, pipeline: ".10f", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: ".10f", arguments: {args: [], kwargs: {}}
      end

      templates[3].tap do |t|
        assert_template t, source: " %p", key: nil, pipeline: "p", embeds: []
        assert_equal 1, t.macros.size
        assert_macro t.macros[0], source: "p", arguments: {args: [], kwargs: {}}
      end
    end
  end
end
