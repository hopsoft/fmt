# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestProcedure < UnitTest
    def test_native
      callable = Fmt.registry[:capitalize]
      ast = ProcedureParser.new(callable).parse
      procedure = Procedure.new(ast)

      assert_equal callable, procedure.callable
      assert_pattern {
        procedure => {
          urtext: "capitalize",
          source: "capitalize",
          key: :capitalize,
          callable: Proc
        }
      }
    end

    def test_rainbow
      callable = Fmt.registry[:cyan]
      ast = ProcedureParser.new(callable).parse
      procedure = Procedure.new(ast)

      assert_equal callable, procedure.callable
      assert_pattern {
        procedure => {
          urtext: "cyan",
          source: "cyan",
          key: :cyan,
          callable: Proc
        }
      }
    end

    def test_custom
      callable = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: callable) do
        ast = ProcedureParser.new(callable).parse
        procedure = Procedure.new(ast)

        assert_equal callable, procedure.callable
        assert_pattern {
          procedure => {
            urtext: "custom",
            source: "custom",
            key: :custom,
            callable: Proc
          }
        }
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
