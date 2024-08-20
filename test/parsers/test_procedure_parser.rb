# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestProcedureParser < UnitTest
    def test_formatter
      callable = Fmt.registry[:%]
      ast = ProcedureParser.new(callable).parse
      assert_instance_of Node, ast
      assert_equal "%", ast.source

      expected = <<~AST
        (procedure
          (key :%))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_native
      callable = Fmt.registry[:capitalize]
      ast = ProcedureParser.new(callable).parse
      assert_instance_of Node, ast
      assert_equal "capitalize", ast.source

      expected = <<~AST
        (procedure
          (key :capitalize))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_rainbow
      callable = Fmt.registry[:magenta]
      ast = ProcedureParser.new(callable).parse
      assert_instance_of Node, ast
      assert_equal "magenta", ast.source

      expected = <<~AST
        (procedure
          (key :magenta))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_custom
      callable = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: callable) do
        ast = ProcedureParser.new(callable).parse
        assert_instance_of Node, ast
        assert_equal "custom", ast.source

        expected = <<~AST
          (procedure
            (key :custom))
        AST
        assert_equal expected.rstrip, ast.to_s
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
