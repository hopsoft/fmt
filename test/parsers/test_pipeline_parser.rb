# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestPipelineParser < UnitTest
    def test_pipeline_with_one_macro
      value = "%s"
      ast = PipelineParser.new(value).parse
      assert_instance_of Node, ast
      assert_equal value, ast.urtext
      assert_equal "sprintf('%s')", ast.source

      expected = <<~AST
        (pipeline
          (macro
            (name :sprintf)
            (arguments
              (tokens
                (lparen "(")
                (tstring-beg "'")
                (tstring-content "%s")
                (tstring-end "'")
                (rparen ")")))))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_pipeline_with_three_macros
      value = "%s|>ljust(80, '.')|>cyan"
      ast = PipelineParser.new(value).parse
      assert_instance_of Node, ast
      assert_equal value, ast.urtext
      assert_equal "sprintf('%s')|>ljust(80, '.')|>cyan", ast.source

      expected = <<~AST
        (pipeline
          (macro
            (name :sprintf)
            (arguments
              (tokens
                (lparen "(")
                (tstring-beg "'")
                (tstring-content "%s")
                (tstring-end "'")
                (rparen ")"))))
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
          (macro
            (name :cyan)))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_named_pipeline
      value = "%<value>.10f|>ljust(80, '.')|>cyan"
      ast = PipelineParser.new(value).parse
      assert_instance_of Node, ast
      assert_equal value, ast.urtext
      assert_equal "sprintf('%<value>.10f')|>ljust(80, '.')|>cyan", ast.source

      expected = <<~AST
        (pipeline
          (macro
            (name :sprintf)
            (arguments
              (tokens
                (lparen "(")
                (tstring-beg "'")
                (tstring-content "%<value>.10f")
                (tstring-end "'")
                (rparen ")"))))
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
          (macro
            (name :cyan)))
      AST

      assert_equal expected.rstrip, ast.to_s
    end

    def test_multiple
      value = "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
      ast = PipelineParser.new(value).parse
      assert_instance_of Node, ast
      assert_equal value, ast.urtext
      assert_equal value, ast.source

      expected = <<~AST
        (pipeline
          (macro
            (name :pluralize)
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
            (name :titleize))
          (macro
            (name :truncate)
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
            (name :red))
          (macro
            (name :bold))
          (macro
            (name :underline)))
      AST

      assert_equal expected.rstrip, ast.to_s
    end
  end
end
