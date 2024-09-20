# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserNative < UnitTest

      # def test_simple
      #   template = "Inspect: %s"
      #   ast = TemplateParser.new(template).parse

      #   assert_instance_of Node, ast
      #   assert_equal template, ast.urtext
      #   assert_equal template, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%s")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end

      # def test_named
      #   template = "Inspect: %{obj}s"
      #   ast = Fmt::TemplateParser.new(template).parse

      #   assert_instance_of Node, ast
      #   assert_equal template, ast.urtext
      #   assert_equal template, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%{obj}s")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end

      # def test_named_alt
      #   template = "Inspect: %<obj>s"
      #   ast = Fmt::TemplateParser.new(template).parse

      #   assert_instance_of Node, ast
      #   assert_equal template, ast.urtext
      #   assert_equal template, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%<obj>s")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end

      # def test_complex
      #   source = "Number: %.10f"
      #   ast = TemplateParser.new(source).parse

      #   assert_instance_of Node, ast
      #   assert_equal source, ast.urtext
      #   assert_equal source, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%.10f")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end

      # def test_complex_named
      #   template = "%<value>.10f"
      #   ast = TemplateParser.new(template).parse

      #   assert_instance_of Node, ast
      #   assert_equal template, ast.urtext
      #   assert_equal template, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%<value>.10f")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end

      # def test_pipeline_named
      #   template = "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')"
      #   ast = TemplateParser.new(template).parse

      #   assert_instance_of Node, ast
      #   assert_equal template, ast.urtext
      #   assert_equal template, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%s")
      #                 (tstring-end "'")
      #                 (rparen ")"))))
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%<value>.10f")
      #                 (tstring-end "'")
      #                 (rparen ")"))))
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%p")
      #                 (tstring-end "'")
      #                 (rparen ")"))))
      #           (macro
      #             (name :truncate)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (int "10")
      #                 (comma ",")
      #                 (sp " ")
      #                 (tstring-beg "'")
      #                 (tstring-content ".")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end

      # def test_multiple
      #   template = "One: %s Two: %.10f Three: %p"
      #   ast = TemplateParser.new(template).parse
      #   assert_equal template, ast.urtext
      #   assert_equal template, ast.source

      #   expected = <<~AST
      #     (template
      #       (pipelines
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%s Two:")
      #                 (tstring-end "'")
      #                 (rparen ")")))))
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%.10f Three:")
      #                 (tstring-end "'")
      #                 (rparen ")")))))
      #         (pipeline
      #           (macro
      #             (name :sprintf)
      #             (arguments
      #               (tokens
      #                 (lparen "(")
      #                 (tstring-beg "'")
      #                 (tstring-content "%p")
      #                 (tstring-end "'")
      #                 (rparen ")")))))))
      #   AST

      #   assert_equal expected.rstrip, ast.to_s
      # end
    end
  end
end
