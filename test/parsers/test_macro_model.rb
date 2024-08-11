# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestMacroModel < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = Fmt::MacroParser.new(source).parse
      model = Fmt::MacroModel.new(ast)

      assert_equal :ljust, model.key
      assert_equal Fmt.registry[:ljust], model.block
      assert_equal [80, "."], model.args
      assert_empty model.kwargs
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"
      ast = Fmt::MacroParser.new(source).parse
      model = Fmt::MacroModel.new(ast)
      assert_equal :truncate, model.key
      assert_equal Fmt.registry[:truncate], model.block
      assert_equal [20], model.args
      assert_equal({omission: "&hellip;"}, model.kwargs)
    end
  end
end
