# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestTemplateParserCustom < UnitTest
    def test_basic
      source = "%cyan"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_basic_named
      source = "%{value}blue"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_basic_named_alt
      source = "%<value>blue"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_named_with_pipeline
      source = "%{value}red|>bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_named_with_pipeline_alt
      source = "%<value>red|>bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples
      source = "Multiple: %red %green %blue"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_named
      source = "Multiple: %{first}red %{second}green %{third}blue"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_named_alt
      source = "Multiple: %<first>red %<second>green %<third>blue"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_mixed
      source = "Multiple: %red %{second}green %<third>blue %bold"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_mixed_with_pipelines
      source = "Multiple: %red|>bold %{second}green|>faint %<third>blue|>italic|>strike %bold|>underline"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end
  end
end
