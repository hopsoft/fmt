# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateNative < UnitTest
      def test_simple
        source = "Inspect: %s"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)

        assert_pattern {
          template => {
            urtext: "Inspect: %s",
            source: "%s",
            pipeline: {
              urtext: "s",
              source: "s",
              macros: [
                {
                  urtext: "s",
                  source: "s",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%s])",
                    source: "(%Q[%s])",
                    args: ["%s"],
                    kwargs: {}
                  }
                }
              ]
            }
          }
        }
      end

      def test_named
        source = "Inspect: %{obj}"
        ast = Fmt::TemplateParser.new(source).parse
        template = Template.new(ast)

        assert_pattern {
          template => {
            urtext: "Inspect: %{obj}",
            source: "%{obj}",
            pipeline: {
              urtext: "{obj}",
              source: "{obj}",
              macros: [
                {
                  urtext: "{obj}",
                  source: "{obj}",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%{obj}])",
                    source: "(%Q[%{obj}])",
                    args: [
                      "%{obj}"
                    ],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "Inspect: %<obj>s",
            source: "%<obj>s",
            pipeline: {
              urtext: "<obj>s",
              source: "<obj>s",
              macros: [
                {
                  urtext: "<obj>s",
                  source: "<obj>s",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%<obj>s])",
                    source: "(%Q[%<obj>s])",
                    args: [
                      "%<obj>s"
                    ],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "%.10f",
            source: "%.10f",
            pipeline: {
              urtext: ".10f",
              source: ".10f",
              macros: [
                {
                  urtext: ".10f",
                  source: ".10f",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%.10f])",
                    source: "(%Q[%.10f])",
                    args: [
                      "%.10f"
                    ],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "%<value>.10f",
            source: "%<value>.10f",
            pipeline: {
              urtext: "<value>.10f",
              source: "<value>.10f",
              macros: [
                {
                  urtext: "<value>.10f",
                  source: "<value>.10f",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%<value>.10f])",
                    source: "(%Q[%<value>.10f])",
                    args: [
                      "%<value>.10f"
                    ],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')",
            source: "%s|><value>.10f|>p|>truncate(10, '.')",
            pipeline: {
              urtext: "s|><value>.10f|>p|>truncate(10, '.')",
              source: "s|><value>.10f|>p|>truncate(10, '.')",
              macros: [
                {
                  urtext: "s",
                  source: "s",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%s])",
                    source: "(%Q[%s])",
                    args: [
                      "%s"
                    ],
                    kwargs: {}
                  }
                },
                {
                  urtext: "<value>.10f",
                  source: "<value>.10f",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%<value>.10f])",
                    source: "(%Q[%<value>.10f])",
                    args: [
                      "%<value>.10f"
                    ],
                    kwargs: {}
                  }
                },
                {
                  urtext: "p",
                  source: "p",
                  name: :sprintf,
                  arguments: {
                    urtext: "sprintf(%Q[%p])",
                    source: "(%Q[%p])",
                    args: [
                      "%p"
                    ],
                    kwargs: {}
                  }
                },
                {
                  urtext: "truncate(10, '.')",
                  source: "truncate(10, '.')",
                  name: :truncate,
                  arguments: {
                    urtext: "truncate(10, '.')",
                    source: "(10, '.')",
                    args: [
                      10,
                      "."
                    ],
                    kwargs: {}
                  }
                }
              ]
            }
          }
        }
      end
    end
  end
end
