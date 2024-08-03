# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestNativeTemplates < UnitTest
    def test_native_basic
      source = "Inspect: %p"
      templates = Fmt::TemplateParser.new(source).parse

      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: "p"
        assert_equal 1, t.specifiers.size
        assert_specifier t.specifiers[0], value: "p", arguments: []
      end
    end

    def test_native_complex
      source = "Precision: %.10f"
      templates = Fmt::TemplateParser.new(source).parse

      assert_equal 1, templates.size

      templates[0].tap do |t|
        assert_template t, source: source, key: nil, pipeline: ".10f"
        assert_equal 1, t.specifiers.size
        assert_specifier t.specifiers[0], value: ".10f", arguments: []
      end
    end

    # def test_native_named
    #  source = "Inspect: %<value>p"
    #  value = Fmt::TemplateParser.new(source).parse
    #   assert_equal ["%p"], value
    # end

    # def test_native_named_alt
    #  source = "Inspect: %{value}p"
    #  value = Fmt::TemplateParser.new(source).parse
    #   assert_equal ["%p"], value
    # end

    # def test_custom
    #  source = "%{value}|>cyan|>truncate(20, separator: '...')|>bold {{%{nate}|>blue|>truncate(20, separator: '...')}}"
    #  value = Fmt::TemplateParser.new(source).parse
    #   assert_equal [source], value
    # end

    # def test_nate
    # source = "%red|bold"
    # end

    # def test_mixed
    # source = "%{key}red|bold: %.10f"
    # value = Fmt::TemplateParser.new(source).parse
    # binding.pry
    # assert_equal ["%<key red|bold>", "%.10f"], value
    # end

    # def test_mixed_alt
    # source = "%<key>red|bold: <value>%.10f"
    # value = Fmt::TemplateParser.new(source).parse
    # assert_equal ["%<value>red|bold", "%<value>.10f"], value
    # end

    # def test_multiple
    # source = "%{one}(cyan|bold):%{two}(cyan|bold) %{three}cyan|bold"
    # value = Fmt::TemplateParser.new(source).parse
    # binding.pry
    # assert_equal [source], value
    # end
  end
end
