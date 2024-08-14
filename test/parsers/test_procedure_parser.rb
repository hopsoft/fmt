# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestProcedureParser < UnitTest
    def test_native
      block = Fmt.registry[:capitalize]
      ast = ProcedureParser.new(block).parse
      assert_instance_of ProcedureAST, ast
      assert_equal "capitalize", ast.source

      expected = <<~AST
        (procedure
          (name :capitalize))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_rainbow
      block = Fmt.registry[:magenta]
      ast = ProcedureParser.new(block).parse
      assert_instance_of ProcedureAST, ast
      assert_equal "magenta", ast.source

      expected = <<~AST
        (procedure
          (name :magenta))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_custom
      block = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: block) do
        ast = ProcedureParser.new(block).parse
        assert_instance_of ProcedureAST, ast
        assert_equal "custom", ast.source

        expected = <<~AST
          (procedure
            (name :custom))
        AST
        assert_equal expected.rstrip, ast.to_s
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
