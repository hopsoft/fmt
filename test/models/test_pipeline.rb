# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestPipeline < UnitTest
    def test_one
      source = "%s|>ljust(80, '.')"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_pattern {
        pipeline => {
          macros: [
            {
              name: :sprintf,
              arguments: {
                args: ["%s"],
                kwargs: {}
              }
            },
            {
              name: :ljust,
              arguments: {
                args: [80, "."],
                kwargs: {}
              }
            }
          ]
        }
      }
    end

    def test_two
      source = "%{value}|>ljust(80, '.')|>cyan"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_pattern {
        pipeline => {
          macros: [
            {
              name: :sprintf,
              arguments: {
                args: ["%{value}"],
                kwargs: {}
              }
            },
            {
              name: :ljust,
              arguments: {
                args: [80, "."],
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
      }
    end

    def test_multiple
      source = "%s|>pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_pattern {
        pipeline => {
          macros: [
            {
              name: :sprintf,
              arguments: {
                args: ["%s"],
                kwargs: {}
              }
            },
            {
              name: :pluralize,
              arguments: {
                args: [2],
                kwargs: {locale: :en}
              }
            },
            {
              name: :titleize,
              arguments: {
                args: [],
                kwargs: {}
              }
            },
            {
              name: :truncate,
              arguments: {
                args: [30, "."],
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
      }
    end
  end
end
