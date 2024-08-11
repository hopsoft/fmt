# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestProcParser < UnitTest
    def test_native
      block = Fmt.registry[:capitalize]
      ast = Fmt::ProcParser.new(block).parse
      assert_instance_of Fmt::ProcAST, ast

      expected = <<~AST
        (proc
          (name :capitalize))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_rainbow
      block = Fmt.registry[:magenta]
      ast = Fmt::ProcParser.new(block).parse
      assert_instance_of Fmt::ProcAST, ast

      expected = <<~AST
        (proc
          (name :magenta))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_custom
      block = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: block) do
        ast = Fmt::ProcParser.new(block).parse
        assert_instance_of Fmt::ProcAST, ast

        expected = <<~AST
          (proc
            (name :custom))
        AST
        assert_equal expected.rstrip, ast.to_s
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
