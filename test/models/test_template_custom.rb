# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Models
    class TestTemplateCustom < UnitTest
      def test_simple
        source = "%cyan"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:cyan], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :cyan)))))"
            },
            urtext: "%cyan",
            source: "%cyan",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :cyan))))"
              },
              urtext: "cyan",
              source: "cyan",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :cyan)))"
                  },
                  urtext: "cyan",
                  source: "cyan",
                  key: :cyan,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_named
        source = "%{value}blue"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:blue], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :blue)))))"
            },
            urtext: "%{value}blue",
            source: "%{value}blue",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :blue))))"
              },
              urtext: "{value}blue",
              source: "{value}blue",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :blue)))"
                  },
                  urtext: "{value}blue",
                  source: "{value}blue",
                  key: :blue,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_named_alt
        source = "%<value>green"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:green], template.pipeline.macros[0].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :green)))))"
            },
            urtext: "%<value>green",
            source: "%<value>green",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :green))))"
              },
              urtext: "<value>green",
              source: "<value>green",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :green)))"
                  },
                  urtext: "<value>green",
                  source: "<value>green",
                  key: :green,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_named_pipeline
        source = "%{value}red|>bold|>underline"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:red], template.pipeline.macros[0].callable
        assert_equal Fmt.registry[:bold], template.pipeline.macros[1].callable
        assert_equal Fmt.registry[:underline], template.pipeline.macros[2].callable

        assert_pattern {
          template => {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :red))) (macro (procedure (key :bold))) (macro (procedure (key :underline)))))"
            },
            urtext: "%{value}red|>bold|>underline",
            source: "%{value}red|>bold|>underline",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :red))) (macro (procedure (key :bold))) (macro (procedure (key :underline))))"
              },
              urtext: "{value}red|>bold|>underline",
              source: "{value}red|>bold|>underline",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :red)))"
                  },
                  urtext: "{value}red",
                  source: "{value}red",
                  key: :red,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :bold)))"
                  },
                  urtext: "bold",
                  source: "bold",
                  key: :bold,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :underline)))"
                  },
                  urtext: "underline",
                  source: "underline",
                  key: :underline,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end

      def test_named_with_pipeline_alt
        source = "%<value>magenta|>italic|>faint"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:magenta], template.pipeline.macros[0].callable
        assert_equal Fmt.registry[:italic], template.pipeline.macros[1].callable
        assert_equal Fmt.registry[:faint], template.pipeline.macros[2].callable

        assert_pattern {
          template = {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :magenta))) (macro (procedure (key :italic))) (macro (procedure (key :faint)))))"
            },
            urtext: "%<value>magenta|>italic|>faint",
            source: "%<value>magenta|>italic|>faint",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :magenta))) (macro (procedure (key :italic))) (macro (procedure (key :faint))))"
              },
              urtext: "<value>magenta|>italic|>faint",
              source: "<value>magenta|>italic|>faint",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :magenta)))"
                  },
                  urtext: "<value>magenta",
                  source: "<value>magenta",
                  key: :magenta,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :italic)))"
                  },
                  urtext: "italic",
                  source: "italic",
                  key: :italic,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                },
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :faint)))"
                  },
                  urtext: "faint",
                  source: "faint",
                  key: :faint,
                  callable: Proc,
                  args: [],
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
