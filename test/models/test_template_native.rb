# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateNative < UnitTest
      def test_simple
        source = "Inspect: %s"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
          ast: {
            node: Node,
            deflated: "(template (pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%s\") (tstring-end \"]\") (rparen \")\"))))))"
          },
          urtext: "Inspect: %s",
          source: "%sprintf(%Q[%s])",
          pipeline: {
            ast: {
              node: Node,
              deflated: "(pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%s\") (tstring-end \"]\") (rparen \")\")))))"
            },
            urtext: "s",
            source: "sprintf(%Q[%s])",
            macros: [
              {
                ast: {
                  node: Node,
                  deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%s\") (tstring-end \"]\") (rparen \")\"))))"
                },
                urtext: "s",
                source: "sprintf(%Q[%s])",
                key: :sprintf,
                callable: Proc,
                args: ["%s"],
                kwargs: {}
              }
            ]
          }
          }
        }
      end

      # def test_named
      #   source = "Inspect: %{obj}s"
      #   ast = Fmt::TemplateParser.new(source).parse
      # end

      # def test_named_alt
      #   source = "Inspect: %<obj>s"
      #   ast = Fmt::TemplateParser.new(source).parse
      # end

      # def test_complex
      #   source = "%.10f"
      #   ast = TemplateParser.new(source).parse
      # end

      # def test_complex_named
      #   source = "%<value>.10f"
      #   ast = TemplateParser.new(source).parse
      # end

      # def test_pipeline_named
      #   source = "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')"
      #   ast = TemplateParser.new(source).parse
      # end
    end
  end
end
