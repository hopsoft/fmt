# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestArgumentsModel < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = Fmt::ArgumentsParser.new(source).parse
      model = Fmt::ArgumentsModel.new(ast)
      assert_equal "(80, '.')", model.source
      assert_equal [80, "."], model.args
      assert_empty model.kwargs
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"
      ast = Fmt::ArgumentsParser.new(source).parse
      model = Fmt::ArgumentsModel.new(ast)
      assert_equal "(20, omission: '&hellip;')", model.source
      assert_equal [20], model.args
      assert_equal({omission: "&hellip;"}, model.kwargs)
    end
  end
end
