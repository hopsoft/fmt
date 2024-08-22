# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestPipeline < UnitTest
    def test_one
      source = "ljust(80, '.')"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_pattern {
        pipeline => {
          urtext: "ljust(80, '.')",
          source: "ljust(80, '.')",
          macros: [{
            urtext: "ljust(80, '.')",
            source: "ljust(80, '.')",
            name: :ljust,
            arguments: {
              args: [80, "."],
              kwargs: {}
            }
          }]
        }
      }
    end

    def test_two
      source = "ljust(80, '.')|>cyan"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_pattern {
        pipeline => {
          urtext: "ljust(80, '.')|>cyan",
          source: "ljust(80, '.')|>cyan",
          macros: [
            {
              urtext: "ljust(80, '.')",
              source: "ljust(80, '.')",
              name: :ljust,
              arguments: {
                args: [80, "."],
                kwargs: {}
              },
            },
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
    end

    def test_multiple
      source = "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_pattern {
        pipeline => {
          urtext: "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline",
          source: "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline",
          macros: [
            {
              urtext: "pluralize(2, locale: :en)",
              source: "pluralize(2, locale: :en)",
              name: :pluralize,
              arguments: {
                args: [2],
                kwargs: {locale: :en}
              }
            },
            {
              urtext: "titleize",
              source: "titleize",
              name: :titleize,
              arguments: {
                args: [],
                kwargs: {}
              }
            },
            {
              urtext: "truncate(30, '.')",
              source: "truncate(30, '.')",
              name: :truncate,
              arguments: {
                args: [30, "."],
                kwargs: {}
              }
            },
            {
              urtext: "red",
              source: "red",
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
    end
  end
end
