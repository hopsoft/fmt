# frozen_string_literal: true

require_relative "../test_helper"

class TestProcModel < UnitTest
  def test_native
    block = Fmt.registry[:capitalize]
    ast = Fmt::ProcParser.new(block).parse
    model = Fmt::ProcModel.new(ast)

    assert_equal Fmt.registry[:capitalize], model.block
    assert_pattern {
      model => {
        source: "capitalize",
        name: :capitalize,
        block: Proc
      }
    }
  end

  def test_rainbow
    block = Fmt.registry[:cyan]
    ast = Fmt::ProcParser.new(block).parse
    model = Fmt::ProcModel.new(ast)

    assert_equal Fmt.registry[:cyan], model.block
    assert_pattern {
      model => {
        source: "cyan",
        name: :cyan,
        block: Proc
      }
    }
  end

  def test_custom
    block = proc { |obj| obj.to_s.upcase }

    Fmt.registry.with_overrides(custom: block) do
      ast = Fmt::ProcParser.new(block).parse
      model = Fmt::ProcModel.new(ast)

      assert_equal Fmt.registry[:custom], model.block
      assert_pattern {
        model => {
          source: "custom",
          name: :custom,
          block: Proc
        }
      }
    end

    refute Fmt.registry.key?(:custom)
  end
end
