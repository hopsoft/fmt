# frozen_string_literal: true

require_relative "../test_helper"

class TestArgumentsModel < UnitTest
  def test_with_positional_args
    source = "ljust(80, '.')"
    ast = Fmt::ArgumentsParser.new(source).parse
    model = Fmt::ArgumentsModel.new(ast)

    assert_pattern {
      model => {
        source: "(80, '.')",
        args: [80, "."],
        kwargs: {}
      }
    }
  end

  def test_with_positional_and_keyword_args
    source = "pluralize(2, locale: :en)"
    ast = Fmt::ArgumentsParser.new(source).parse
    model = Fmt::ArgumentsModel.new(ast)

    assert_pattern {
      model => {
        source: "(2, locale: :en)",
        args: [2],
        kwargs: {locale: :en}
      }
    }
  end
end
