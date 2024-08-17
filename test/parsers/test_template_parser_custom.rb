# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserCustom < UnitTest
      def test_simple
        source = "%cyan"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal source, ast.source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (procedure
                  (name :cyan)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named
        source = "%{value}blue"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<value>blue", ast.source

        expected = <<~AST
          (template
            (key "value")
            (pipeline
              (macro
                (procedure
                  (name :blue)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_alt
        source = "%<value>blue"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal source, ast.source

        expected = <<~AST
          (template
            (key "value")
            (pipeline
              (macro
                (procedure
                  (name :blue)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_pipeline
        source = "%{value}red|>bold|>underline"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<value>red|>bold|>underline", ast.source

        expected = <<~AST
          (template
            (key "value")
            (pipeline
              (macro
                (procedure
                  (name :red)))
              (macro
                (procedure
                  (name :bold)))
              (macro
                (procedure
                  (name :underline)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end

      def test_named_with_pipeline_alt
        source = "%<value>red|>bold|>underline"
        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal source, ast.source

        expected = <<~AST
          (template
            (key "value")
            (pipeline
              (macro
                (procedure
                  (name :red)))
              (macro
                (procedure
                  (name :bold)))
              (macro
                (procedure
                  (name :underline)))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end
    end
  end
end
