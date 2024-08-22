# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Models
    class TestTemplateCustom < UnitTest
      def test_simple
        source = "%cyan"
        ast = TemplateParser.new(source).parse
        template = Template.new(ast)

        assert_pattern {
          template => {
            urtext: "%cyan",
            source: "%cyan",
            pipeline: {
              urtext: "cyan",
              source: "cyan",
              macros: [
                {
                  urtext: "cyan",
                  source: "cyan",
                  name: :cyan,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "%{value}blue",
            source: "%{value}blue",
            pipeline: {
              urtext: "{value}blue",
              source: "{value}blue",
              macros: [
                {
                  urtext: "{value}blue",
                  source: "{value}blue",
                  name: :blue,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "%<value>green",
            source: "%<value>green",
            pipeline: {
              urtext: "<value>green",
              source: "<value>green",
              macros: [
                {
                  urtext: "<value>green",
                  source: "<value>green",
                  name: :green,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
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

        assert_pattern {
          template => {
            urtext: "%{value}red|>bold|>underline",
            source: "%{value}red|>bold|>underline",
            pipeline: {
              urtext: "{value}red|>bold|>underline",
              source: "{value}red|>bold|>underline",
              macros: [
                {
                  urtext: "{value}red",
                  source: "{value}red",
                  name: :red,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
                },
                {
                  urtext: "bold",
                  source: "bold",
                  name: :bold,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
                },
                {
                  urtext: "underline",
                  source: "underline",
                  name: :underline,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
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

        assert_pattern {
          template = {
            urtext: "%<value>magenta|>italic|>faint",
            source: "%<value>magenta|>italic|>faint",
            pipeline: {
              urtext: "<value>magenta|>italic|>faint",
              source: "<value>magenta|>italic|>faint",
              macros: [
                {
                  urtext: "<value>magenta",
                  source: "<value>magenta",
                  name: :magenta,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
                },
                {
                  urtext: "italic",
                  source: "italic",
                  name: :italic,
                  arguments: {
                    args: [],
                    kwargs: {}
                  }
                },
                {
                  urtext: "faint",
                  source: "faint",
                  name: :faint,
                  arguments: {
                    args: [],
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
