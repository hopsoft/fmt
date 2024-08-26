# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateNative < UnitTest
      def test_simple
        source = "Inspect: %s"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%s"],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_named
        source = "Inspect: %{obj}"
        ast = Fmt::TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%{obj}"],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_named_alt
        source = "Inspect: %<obj>s"
        ast = Fmt::TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%<obj>s"],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_complex
        source = "%.10f"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%.10f"],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_complex_named
        source = "%<value>.10f"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%<value>.10f"],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_pipeline_named
        source = "Pipleline: %s|><value>.10f|>p|>truncate(10, '.')"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%s"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%<value>.10f"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%p"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :truncate,
                    arguments: {
                      args: [10, "."],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_multiple
        template = "One: %s Two: %.10f Three: %{value} %p"
        ast = TemplateParser.new(template).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template => {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%s"],
                      kwargs: {}
                    }
                  }
                ]
              },
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%.10f"],
                      kwargs: {}
                    }
                  }
                ]
              },
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%{value}"],
                      kwargs: {}
                    }
                  }
                ]
              },
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%p"],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end
    end
  end
end
