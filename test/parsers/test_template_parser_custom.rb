# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserCustom < UnitTest
      def test_simple
        template = "%cyan"
        ast = TemplateParser.new(template).parse

        assert_instance_of Node, ast
        assert_equal template, ast.urtext
        assert_equal template, ast.source

        expected = <<~AST
          (template
            (pipelines
              (pipeline
                (macro
                  (name :cyan)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named
        template = "%{value}blue"
        ast = TemplateParser.new(template).parse

        assert_instance_of Node, ast
        assert_equal template, ast.urtext
        assert_equal template, ast.source

        expected = <<~AST
          (template
            (pipelines
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%{value}")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :blue)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_alt
        template = "%<value>blue"
        ast = TemplateParser.new(template).parse

        assert_instance_of Node, ast
        assert_equal template, ast.urtext
        assert_equal template, ast.source

        expected = <<~AST
          (template
            (pipelines
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%<value>")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :blue)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_pipeline
        template = "%{value}red|>bold|>underline"
        ast = TemplateParser.new(template).parse

        assert_instance_of Node, ast
        assert_equal template, ast.urtext
        assert_equal template, ast.source

        expected = <<~AST
          (template
            (pipelines
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%{value}")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :red))
                (macro
                  (name :bold))
                (macro
                  (name :underline)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_with_pipeline_alt
        template = "%<value>red|>bold|>underline"
        ast = TemplateParser.new(template).parse

        assert_instance_of Node, ast
        assert_equal template, ast.urtext
        assert_equal template, ast.source

        expected = <<~AST
          (template
            (pipelines
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%<value>")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :red))
                (macro
                  (name :bold))
                (macro
                  (name :underline)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_multiple
        template = "One: %s|>red Two: %{two}blue|>underline Three: %<three>green|>italic|>bold"
        ast = TemplateParser.new(template).parse
        assert_equal template, ast.urtext
        assert_equal template, ast.source

        expected = <<~AST
          (template
            (pipelines
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%s")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :red)))
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%{two}")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :blue))
                (macro
                  (name :underline)))
              (pipeline
                (macro
                  (name :sprintf)
                  (arguments
                    (tokens
                      (lparen "(")
                      (tstring-beg "%Q[")
                      (tstring-content "%<three>")
                      (tstring-end "]")
                      (rparen ")"))))
                (macro
                  (name :green))
                (macro
                  (name :italic))
                (macro
                  (name :bold)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end
    end
  end
end
