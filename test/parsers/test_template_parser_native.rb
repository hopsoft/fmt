# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserNative < UnitTest
      def test_simple
        source = "Inspect: %s"
        ast = TemplateParser.new(source).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%sprintf(%Q[%s])", ast.source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (procedure
                  (name :sprintf))
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

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<obj>sprintf(%Q[%s])", ast.source

        expected = <<~AST
          (template
            (key "obj")
            (pipeline
              (macro
                (procedure
                  (name :sprintf))
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

      def test_named_alt
        source = "Inspect: %<obj>s"
        ast = Fmt::TemplateParser.new(source).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<obj>sprintf(%Q[%s])", ast.source

        expected = <<~AST
          (template
            (key "obj")
            (pipeline
              (macro
                (procedure
                  (name :sprintf))
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

      def test_complex
        source = "%.10f"
        ast = TemplateParser.new(source).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%sprintf(%Q[%.10f])", ast.source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (procedure
                  (name :sprintf))
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

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<value>sprintf(%Q[%.10f])", ast.source

        expected = <<~AST
          (template
            (key "value")
            (pipeline
              (macro
                (procedure
                  (name :sprintf))
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

      def test_pipeline_named
        source = "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')"
        ast = TemplateParser.new(source).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<value>sprintf(%Q[%.10f])|>sprintf(%Q[%p])|>truncate(10, '.')", ast.source

        expected = <<~AST
          (template
            (key "value")
            (pipeline
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
              (macro
                (procedure
                  (name :sprintf))
                (arguments
                  (tokens
                    (lparen "(")
                    (tstring-beg "%Q[")
                    (tstring-content "%p")
                    (tstring-end "]")
                    (rparen ")"))))
              (macro
                (procedure
                  (name :truncate))
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
