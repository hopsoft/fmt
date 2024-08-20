# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestMacro < UnitTest
    def test_without_args
      source = "strip"
      ast = MacroParser.new(source).parse
      macro = Macro.new(ast)
      assert_equal Fmt.registry[:strip], macro.callable

      assert_pattern {
        macro => {
          urtext: "strip",
          source: "strip",
          key: :strip,
          callable: Proc,
          args: [],
          kwargs: {}
        }
      }
    end

    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = MacroParser.new(source).parse
      macro = Macro.new(ast)

      assert_equal Fmt.registry[:ljust], macro.callable
      assert_pattern {
        macro => {
          urtext: "ljust(80, '.')",
          source: "ljust(80, '.')",
          key: :ljust,
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
          urtext: "truncate(20, omission: '&hellip;')",
          source: "truncate(20, omission: '&hellip;')",
          key: :truncate,
          callable: Proc,
          args: [20],
          kwargs: {omission: "&hellip;"}
        }
      }
    end
  end
end
