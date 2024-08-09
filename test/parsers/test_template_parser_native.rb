# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestTemplateParserNative < UnitTest
    def test_basic
      source = "Inspect: %p"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_basic_named
      source = "Inspect: %{obj}p"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_basic_named_alt
      source = "Inspect: %<obj>p"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_complex
      source = "Precision: %.10f"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_complex_named
      source = "Precision: %{obj}.10f"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_complex_named_alt
      source = "Precision: %<obj>.10f"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples
      source = "Multiple: %p %.10f"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_named
      source = "Multiple: %{obj}p %{num}.10f"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_named_alt
      source = "Multiple: %<obj>p %<num>.10f"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_multiples_mixed
      source = "Multiple: %s %{obj}p %<num>.10f %p"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end
  end
end
