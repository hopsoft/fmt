# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestMacroParser < UnitTest
    def test_formatter_simple
      source = "s"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf('%s')", ast.source
      assert_equal "('%s')", ast.find(:arguments).source

      expected = <<~AST
        (macro
          (name :sprintf)
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "'")
              (tstring-content "%s")
              (tstring-end "'")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_complex
      source = ".10f"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf('%.10f')", ast.source
      assert_equal "('%.10f')", ast.find(:arguments).source

      expected = <<~AST
        (macro
          (name :sprintf)
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "'")
              (tstring-content "%.10f")
              (tstring-end "'")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_named
      source = "{value}"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf('%{value}')", ast.source
      assert_equal "('%{value}')", ast.find(:arguments).source

      expected = <<~AST
        (macro
          (name :sprintf)
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "'")
              (tstring-content "%{value}")
              (tstring-end "'")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_named_alt
      source = "<value>s"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf('%<value>s')", ast.source
      assert_equal "('%<value>s')", ast.find(:arguments).source

      expected = <<~AST
        (macro
          (name :sprintf)
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "'")
              (tstring-content "%<value>s")
              (tstring-end "'")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_formatter_complex_named
      source = "<value>.10f"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal "sprintf('%<value>.10f')", ast.source
      assert_equal "('%<value>.10f')", ast.find(:arguments).source

      expected = <<~AST
        (macro
          (name :sprintf)
          (arguments
            (tokens
              (lparen "(")
              (tstring-beg "'")
              (tstring-content "%<value>.10f")
              (tstring-end "'")
              (rparen ")"))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_method_without_args
      source = "strip"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (name :strip))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_callable_with_positional_args
      source = "ljust(80, '.')"
      ast = MacroParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (name :ljust)
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
      assert_instance_of Node, ast
      assert_equal source, ast.urtext
      assert_equal source, ast.source

      expected = <<~AST
        (macro
          (name :truncate)
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
