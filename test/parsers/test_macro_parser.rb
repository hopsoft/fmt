# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestMacroParser < UnitTest
    def test_formatter_simple
      source = "s"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf(%Q[%s])", ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :sprintf))
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "%Q[")
              (tstring-content "%s")
              (tstring-end "]")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_complex
      source = ".10f"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf(%Q[%.10f])", ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :sprintf))
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "%Q[")
              (tstring-content "%.10f")
              (tstring-end "]")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_named
      source = "{value}s"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf(%Q[%{value}s])", ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :sprintf))
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "%Q[")
              (tstring-content "%{value}s")
              (tstring-end "]")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_named_alt
      source = "<value>s"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf(%Q[%<value>s])", ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :sprintf))
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "%Q[")
              (tstring-content "%<value>s")
              (tstring-end "]")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_complex_named
      source = "<value>.10f"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf(%Q[%<value>.10f])", ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :sprintf))
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "%Q[")
              (tstring-content "%<value>.10f")
              (tstring-end "]")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_callable_without_args
      source = "strip"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (procedure
            (name :strip)))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_callable_with_positional_args
      source = "ljust(80, '.')"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
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

    def test_callable_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"
      ast = MacroParser.new(source).parse
      assert_instance_of MacroNode, ast
      assert_equal source, ast.urtext
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
