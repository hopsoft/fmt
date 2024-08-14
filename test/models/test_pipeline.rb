# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  class TestPipeline < UnitTest
    def test_one
      source = "ljust(80, '.')"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_equal Fmt.registry[:ljust], pipeline.macros[0].callable
      assert_pattern {
        pipeline => {
          source: "ljust(80, '.')",
          macros: [{
            source: "ljust(80, '.')",
            name: :ljust,
            callable: Proc,
            args: [80, "."],
            kwargs: {}
          }]
        }
      }
    end

    def test_two
      source = "ljust(80, '.')|>cyan"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_equal Fmt.registry[:ljust], pipeline.macros[0].callable
      assert_equal Fmt.registry[:cyan], pipeline.macros[1].callable
      assert_pattern {
        pipeline => {
          source: "ljust(80, '.')|>cyan",
          macros: [
            {
              source: "ljust(80, '.')",
              name: :ljust,
              callable: Proc,
              args: [80, "."],
              kwargs: {}
            },
            {
              source: "cyan",
              name: :cyan,
              callable: Proc,
              args: [],
              kwargs: {}
            }
          ]
        }
      }
    end

    def test_multiple
      source = "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
      ast = PipelineParser.new(source).parse
      pipeline = Pipeline.new(ast)

      assert_equal Fmt.registry[:pluralize], pipeline.macros[0].callable
      assert_equal Fmt.registry[:titleize], pipeline.macros[1].callable
      assert_equal Fmt.registry[:truncate], pipeline.macros[2].callable
      assert_equal Fmt.registry[:red], pipeline.macros[3].callable
      assert_equal Fmt.registry[:bold], pipeline.macros[4].callable
      assert_equal Fmt.registry[:underline], pipeline.macros[5].callable
      assert_pattern {
        pipeline => {
          source: "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline",
          macros: [
            {
              source: "pluralize(2, locale: :en)",
              name: :pluralize,
              callable: Proc,
              args: [2],
              kwargs: {locale: :en}
            },
            {
              source: "titleize",
              name: :titleize,
              callable: Proc,
              args: [],
              kwargs: {}
            },
            {
              source: "truncate(30, '.')",
              name: :truncate,
              callable: Proc,
              args: [30, "."],
              kwargs: {}
            },
            {
              source: "red",
              name: :red,
              callable: Proc,
              args: [],
              kwargs: {}
            },
            {
              source: "bold",
              name: :bold,
              callable: Proc,
              args: [],
              kwargs: {}
            },
            {
              source: "underline",
              name: :underline,
              callable: Proc,
              args: [],
              kwargs: {}
            }
          ]
        }
      }
    end
  end
end
