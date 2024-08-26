# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Models
    class TestTemplateCustom < UnitTest
      def test_simple
        source = "%s|>cyan"
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
                    name: :cyan,
                    arguments: {
                      args: [],
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
        source = "%{value}blue"
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
                      args: ["%{value}"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :blue,
                    arguments: {
                      args: [],
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
        source = "%<value>green"
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
                      args: ["%<value>"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :green,
                    arguments: {
                      args: [],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_named_pipeline
        source = "%{value}red|>bold|>underline"
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
                      args: ["%{value}"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :red,
                    arguments: {
                      args: [],
                      kwargs: {}
                    }
                  },
                  {
                    name: :bold,
                    arguments: {
                      args: [],
                      kwargs: {}
                    }
                  },
                  {
                    name: :underline,
                    arguments: {
                      args: [],
                      kwargs: {}
                    }
                  }
                ]
              }
            ]
          }
        }
      end

      def test_named_with_pipeline_alt
        source = "%<value>magenta|>italic|>faint"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_instance_of Template, template

        assert_pattern {
          template = {
            embeds: [],
            pipelines: [
              {
                macros: [
                  {
                    name: :sprintf,
                    arguments: {
                      args: ["%<value>"],
                      kwargs: {}
                    }
                  },
                  {
                    name: :magenta,
                    arguments: {
                      args: [],
                      kwargs: {}
                    }
                  },
                  {
                    name: :italic,
                    arguments: {
                      args: [],
                      kwargs: {}
                    }
                  },
                  {
                    name: :faint,
                    arguments: {
                      args: [],
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
