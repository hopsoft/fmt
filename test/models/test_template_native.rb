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

      def test_named
        source = "Inspect: %{obj}s"
        ast = Fmt::TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%{obj}s\") (tstring-end \"]\") (rparen \")\"))))))"
            },
            urtext: "Inspect: %{obj}s",
            source: "%sprintf(%Q[%{obj}s])",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%{obj}s\") (tstring-end \"]\") (rparen \")\")))))"
              },
              urtext: "{obj}s",
              source: "sprintf(%Q[%{obj}s])",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%{obj}s\") (tstring-end \"]\") (rparen \")\"))))"
                  },
                  urtext: "{obj}s",
                  source: "sprintf(%Q[%{obj}s])",
                  key: :sprintf,
                  callable: Proc,
                  args: [
                    "%{obj}s"
                  ],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_named_alt
        source = "Inspect: %<obj>s"
        ast = Fmt::TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<obj>s\") (tstring-end \"]\") (rparen \")\"))))))"
            },
            urtext: "Inspect: %<obj>s",
            source: "%sprintf(%Q[%<obj>s])",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<obj>s\") (tstring-end \"]\") (rparen \")\")))))"
              },
              urtext: "<obj>s",
              source: "sprintf(%Q[%<obj>s])",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<obj>s\") (tstring-end \"]\") (rparen \")\"))))"
                  },
                  urtext: "<obj>s",
                  source: "sprintf(%Q[%<obj>s])",
                  key: :sprintf,
                  callable: Proc,
                  args: [
                    "%<obj>s"
                  ],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_complex
        source = "%.10f"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%.10f\") (tstring-end \"]\") (rparen \")\"))))))"
            },
            urtext: "%.10f",
            source: "%sprintf(%Q[%.10f])",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%.10f\") (tstring-end \"]\") (rparen \")\")))))"
              },
              urtext: ".10f",
              source: "sprintf(%Q[%.10f])",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%.10f\") (tstring-end \"]\") (rparen \")\"))))"
                  },
                  urtext: ".10f",
                  source: "sprintf(%Q[%.10f])",
                  key: :sprintf,
                  callable: Proc,
                  args: [
                    "%.10f"
                  ],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_complex_named
        source = "%<value>.10f"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<value>.10f\") (tstring-end \"]\") (rparen \")\"))))))"
            },
            urtext: "%<value>.10f",
            source: "%sprintf(%Q[%<value>.10f])",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<value>.10f\") (tstring-end \"]\") (rparen \")\")))))"
              },
              urtext: "<value>.10f",
              source: "sprintf(%Q[%<value>.10f])",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<value>.10f\") (tstring-end \"]\") (rparen \")\"))))"
                  },
                  urtext: "<value>.10f",
                  source: "sprintf(%Q[%<value>.10f])",
                  key: :sprintf,
                  callable: Proc,
                  args: [
                    "%<value>.10f"
                  ],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_pipeline_named
        source = "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[0].callable
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[1].callable
        assert_equal Fmt.registry[:sprintf], template.pipeline.macros[2].callable
        assert_equal Fmt.registry[:truncate], template.pipeline.macros[3].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%s\") (tstring-end \"]\") (rparen \")\")))) (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<value>.10f\") (tstring-end \"]\") (rparen \")\")))) (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%p\") (tstring-end \"]\") (rparen \")\")))) (macro (procedure (key :truncate)) (arguments (tokens (lparen \"(\") (int \"10\") (comma \",\") (sp \" \") (tstring-beg \"'\") (tstring-content \".\") (tstring-end \"'\") (rparen \")\"))))))"
            },
            urtext: "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')",
            source: "%sprintf(%Q[%s])|>sprintf(%Q[%<value>.10f])|>sprintf(%Q[%p])|>truncate(10, '.')",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%s\") (tstring-end \"]\") (rparen \")\")))) (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<value>.10f\") (tstring-end \"]\") (rparen \")\")))) (macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%p\") (tstring-end \"]\") (rparen \")\")))) (macro (procedure (key :truncate)) (arguments (tokens (lparen \"(\") (int \"10\") (comma \",\") (sp \" \") (tstring-beg \"'\") (tstring-content \".\") (tstring-end \"'\") (rparen \")\")))))"
              },
              urtext: "s|><value>.10f|>p|>truncate(10, '.')",
              source: "sprintf(%Q[%s])|>sprintf(%Q[%<value>.10f])|>sprintf(%Q[%p])|>truncate(10, '.')",
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
                  args: [
                    "%s"
                  ],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%<value>.10f\") (tstring-end \"]\") (rparen \")\"))))"
                  },
                  urtext: "<value>.10f",
                  source: "sprintf(%Q[%<value>.10f])",
                  key: :sprintf,
                  callable: Proc,
                  args: [
                    "%<value>.10f"
                  ],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :sprintf)) (arguments (tokens (lparen \"(\") (tstring-beg \"%Q[\") (tstring-content \"%p\") (tstring-end \"]\") (rparen \")\"))))"
                  },
                  urtext: "p",
                  source: "sprintf(%Q[%p])",
                  key: :sprintf,
                  callable: Proc,
                  args: [
                    "%p"
                  ],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :truncate)) (arguments (tokens (lparen \"(\") (int \"10\") (comma \",\") (sp \" \") (tstring-beg \"'\") (tstring-content \".\") (tstring-end \"'\") (rparen \")\"))))"
                  },
                  urtext: "truncate(10, '.')",
                  source: "truncate(10, '.')",
                  key: :truncate,
                  callable: Proc,
                  args: [
                    10,
                    "."
                  ],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end
    end
  end
end
