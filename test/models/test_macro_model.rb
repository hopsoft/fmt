# frozen_string_literal: true

require_relative "../test_helper"

class TestMacroModel < UnitTest
  def test_with_positional_args
    source = "ljust(80, '.')"
    ast = Fmt::MacroParser.new(source).parse
    model = Fmt::MacroModel.new(ast)

    assert_equal Fmt.registry[:ljust], model.block
    assert_pattern {
      model => {
        source: "ljust(80, '.')",
        name: :ljust,
        block: Proc,
        args: [80, "."],
        kwargs: {}
      }
    }
  end

  def test_with_positional_and_keyword_args
    source = "truncate(20, omission: '&hellip;')"
    ast = Fmt::MacroParser.new(source).parse
    model = Fmt::MacroModel.new(ast)

    assert_equal Fmt.registry[:truncate], model.block
    assert_pattern {
      model => {
        source: "truncate(20, omission: '&hellip;')",
        name: :truncate,
        block: Proc,
        args: [20],
        kwargs: {omission: "&hellip;"}
      }
    }
  end
end
