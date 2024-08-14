# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestArguments < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = ArgumentsParser.new(source).parse
      model = Arguments.new(ast)

      assert_pattern {
        model => {
          urtext: "ljust(80, '.')",
          source: "(80, '.')",
          args: [80, "."],
          kwargs: {}
        }
      }
    end

    def test_with_positional_and_keyword_args
      source = "pluralize(2, locale: :en)"
      ast = ArgumentsParser.new(source).parse
      model = Arguments.new(ast)

      assert_pattern {
        model => {
          urtext: "pluralize(2, locale: :en)",
          source: "(2, locale: :en)",
          args: [2],
          kwargs: {locale: :en}
        }
      }
    end
  end
end
