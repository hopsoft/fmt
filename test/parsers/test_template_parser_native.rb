# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserNative < UnitTest
      def test_simple
        source = "Inspect: %s"
        ast = TemplateParser.new(source).parse

        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%s", ast.source
        assert_equal "s", ast.find(:pipeline).source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%s")
                    (tstring-end "]")
                    (rparen ")"))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named
        source = "Inspect: %{obj}s"
        ast = Fmt::TemplateParser.new(source).parse

        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%{obj}s", ast.source
        assert_equal "{obj}s", ast.find(:pipeline).source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%{obj}s")
                    (tstring-end "]")
                    (rparen ")"))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_alt
        source = "Inspect: %<obj>s"
        ast = Fmt::TemplateParser.new(source).parse

        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%<obj>s", ast.source
        assert_equal "<obj>s", ast.find(:pipeline).source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%<obj>s")
                    (tstring-end "]")
                    (rparen ")"))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_complex
        source = "Number: %.10f"
        ast = TemplateParser.new(source).parse

        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%.10f", ast.source
        assert_equal ".10f", ast.find(:pipeline).source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%.10f")
                    (tstring-end "]")
                    (rparen ")"))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_complex_named
        source = "%<value>.10f"
        ast = TemplateParser.new(source).parse

        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%<value>.10f", ast.source
        assert_equal "<value>.10f", ast.find(:pipeline).source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%<value>.10f")
                    (tstring-end "]")
                    (rparen ")"))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_pipeline_named
        source = "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')"
        ast = TemplateParser.new(source).parse

        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%s|><value>.10f|>p|>truncate(10, '.')", ast.source
        assert_equal "s|><value>.10f|>p|>truncate(10, '.')", ast.find(:pipeline).source

        expected = <<~AST
          (template
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
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%<value>.10f")
                    (tstring-end "]")
                    (rparen ")"))))
              (macro
                (name :sprintf)
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%p")
                    (tstring-end "]")
                    (rparen ")"))))
              (macro
                (name :truncate)
                (arguments
                  (tokens
                    (lparen "(")
                    (int "10")
                    (comma ",")
                    (sp " ")
                    (tstring-beg "'")
                    (tstring-content ".")
                    (tstring-end "'")
                    (rparen ")"))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end
    end
  end
end
