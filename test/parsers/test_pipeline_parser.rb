# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestPipelineParser < UnitTest
    def test_one
      source = "ljust(80, '.')"
      ast = PipelineParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.source

      expected = <<~AST
        (pipeline
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
                (rparen ")")))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_two
      source = "ljust(80, '.')|>cyan"
      ast = PipelineParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.source

      expected = <<~AST
        (pipeline
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
          (macro
            (procedure
              (name :cyan))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_named
      source = "<value>.10f|>ljust(80, '.')|>cyan"
      ast = PipelineParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal "sprintf(%Q[%<value>.10f])|>ljust(80, '.')|>cyan", ast.source

      expected = <<~AST
        (pipeline
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
          (macro
            (procedure
              (name :cyan))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_multiple
      source = "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
      ast = PipelineParser.new(source).parse
      assert_instance_of Node, ast
      assert_equal source, ast.source

      expected = <<~AST
        (pipeline
          (macro
            (procedure
              (name :pluralize))
            (arguments
              (tokens
                (lparen "(")
                (int "2")
                (comma ",")
                (sp " ")
                (label "locale:")
                (sp " ")
                (symbeg ":")
                (ident "en")
                (rparen ")"))))
          (macro
            (procedure
              (name :titleize)))
          (macro
            (procedure
              (name :truncate))
            (arguments
              (tokens
                (lparen "(")
                (int "30")
                (comma ",")
                (sp " ")
                (tstring-beg "'")
                (tstring-content ".")
                (tstring-end "'")
                (rparen ")"))))
          (macro
            (procedure
              (name :red)))
          (macro
            (procedure
              (name :bold)))
          (macro
            (procedure
              (name :underline))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end
  end
end
