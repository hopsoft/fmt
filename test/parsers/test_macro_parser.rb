# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestMacroParser < UnitTest
    def test_without_args
      source = "strip"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroAST, ast
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :strip)))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroAST, ast
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :ljust))
          (arguments
            (tokens
              (lparen "(")
              (int "80")
              (comma ",")
              (sp " ")
              (tstring-beg "'")
              (tstring-content ".")
              (tstring-end "'")
              (rparen ")"))))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroAST, ast
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :truncate))
          (arguments
            (tokens
              (lparen "(")
              (int "20")
              (comma ",")
              (sp " ")
              (label "omission:")
              (sp " ")
              (tstring-beg "'")
              (tstring-content "&hellip;")
              (tstring-end "'")
              (rparen ")"))))
      AST
      assert_equal expected.rstrip, ast.to_s
    end
  end
end
