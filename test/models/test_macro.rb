# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestMacro < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = MacroParser.new(source).parse
      macro = Macro.new(ast)

      assert_equal Fmt.registry[:ljust], macro.callable
      assert_pattern {
        macro => {
          source: "ljust(80, '.')",
          name: :ljust,
          callable: Proc,
          args: [80, "."],
          kwargs: {}
        }
      }
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"
      ast = MacroParser.new(source).parse
      macro = Macro.new(ast)

      assert_equal Fmt.registry[:truncate], macro.callable
      assert_pattern {
        macro => {
          source: "truncate(20, omission: '&hellip;')",
          name: :truncate,
          callable: Proc,
          args: [20],
          kwargs: {omission: "&hellip;"}
        }
      }
    end
  end
end
