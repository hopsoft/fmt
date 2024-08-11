# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestArgumentsParser < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"
      ast = Fmt::ArgumentsParser.new(source).parse
      assert_instance_of Fmt::ArgumentsAST, ast

      expected = <<~AST
        (arguments
          (tokens
            (lparen "(")
            (int "80")
            (comma ",")
            (sp " ")
            (tstring-beg "'")
            (tstring-content ".")
            (tstring-end "'")
            (rparen ")")))
      AST
      assert_equal expected.rstrip, ast.to_s
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"
      ast = Fmt::ArgumentsParser.new(source).parse
      assert_instance_of Fmt::ArgumentsAST, ast

      expected = <<~AST
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
            (rparen ")")))
      AST
      assert_equal expected.rstrip, ast.to_s
    end
  end
end
