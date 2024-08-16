# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserNative < UnitTest
      def test_formatter
        source = "Inspect: %s"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateAST, ast
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

      def test_formatter_named
        source = "Inspect: %{obj}s"
        scanner = StringScanner.new(source)
        ast = Fmt::TemplateParser.new(scanner).parse

        assert_instance_of TemplateAST, ast
        assert_equal source, ast.urtext
        assert_equal "%{obj}sprintf(%Q[%s])", ast.source

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

      def test_formatter_named_alt
        source = "Inspect: %<obj>s"
        scanner = StringScanner.new(source)
        ast = Fmt::TemplateParser.new(scanner).parse

        assert_instance_of TemplateAST, ast
        assert_equal source, ast.urtext
        assert_equal "%{obj}sprintf(%Q[%s])", ast.source

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

      def test_formatter_complex
        source = "%.10f"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateAST, ast
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

      def test_formatter_complex_named
        source = "%<value>.10f"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateAST, ast
        assert_equal source, ast.urtext
        assert_equal "%{value}sprintf(%Q[%.10f])", ast.source

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
        source = "Multiple: %s|><value>.10f|>p|>truncate(10, '.')"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateAST, ast
        assert_equal source, ast.urtext
        assert_equal "%{value}sprintf(%Q[%.10f])|>sprintf(%Q[%p])|>truncate(10, '.')", ast.source

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

      def test_embeds
        # todo: embeds
      end
    end
  end
end
