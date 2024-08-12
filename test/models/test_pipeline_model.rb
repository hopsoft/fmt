# frozen_string_literal: true

require_relative "../test_helper"

class TestPipelineModel < UnitTest
  def test_one
    source = "ljust(80, '.')"
    ast = Fmt::PipelineParser.new(source).parse
    model = Fmt::PipelineModel.new(ast)

    assert_equal Fmt.registry[:ljust], model.macros[0].block
    assert_pattern {
      model => {
        source: "ljust(80, '.')",
        macros: [{
          source: "ljust(80, '.')",
          name: :ljust,
          block: Proc,
          args: [80, "."],
          kwargs: {}
        }]
      }
    }
  end

  def test_two
    source = "ljust(80, '.')|>cyan"
    ast = Fmt::PipelineParser.new(source).parse
    model = Fmt::PipelineModel.new(ast)

    assert_equal Fmt.registry[:ljust], model.macros[0].block
    assert_equal Fmt.registry[:cyan], model.macros[1].block
    assert_pattern {
      model => {
        source: "ljust(80, '.')|>cyan",
        macros: [
          {
            source: "ljust(80, '.')",
            name: :ljust,
            block: Proc,
            args: [80, "."],
            kwargs: {}
          },
          {
            source: "cyan",
            name: :cyan,
            block: Proc,
            args: [],
            kwargs: {}
          }
        ]
      }
    }
  end

  def test_multiple
    source = "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
    ast = Fmt::PipelineParser.new(source).parse
    model = Fmt::PipelineModel.new(ast)

    assert_equal Fmt.registry[:pluralize], model.macros[0].block
    assert_equal Fmt.registry[:titleize], model.macros[1].block
    assert_equal Fmt.registry[:truncate], model.macros[2].block
    assert_equal Fmt.registry[:red], model.macros[3].block
    assert_equal Fmt.registry[:bold], model.macros[4].block
    assert_equal Fmt.registry[:underline], model.macros[5].block
    assert_pattern {
      model => {
        source: "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline",
        macros: [
          {
            source: "pluralize(2, locale: :en)",
            name: :pluralize,
            block: Proc,
            args: [2],
            kwargs: {locale: :en}
          },
          {
            source: "titleize",
            name: :titleize,
            block: Proc,
            args: [],
            kwargs: {}
          },
          {
            source: "truncate(30, '.')",
            name: :truncate,
            block: Proc,
            args: [30, "."],
            kwargs: {}
          },
          {
            source: "red",
            name: :red,
            block: Proc,
            args: [],
            kwargs: {}
          },
          {
            source: "bold",
            name: :bold,
            block: Proc,
            args: [],
            kwargs: {}
          },
          {
            source: "underline",
            name: :underline,
            block: Proc,
            args: [],
            kwargs: {}
          }
        ]
      }
    }
  end
end
