# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestArgsParser < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"

      parser = Fmt::ArgsParser.new(source)
      model = parser.parse

      expected = <<~AST
        (args
          (tokens
            (lparen "(")
            (int "80")
            (comma ",")
            (sp " ")
            (tstring-beg "'")
            (tstring-content ".")
            (tstring-end "'")
            (rparen ")")))
      AST

      assert_equal expected.rstrip, model.ast.to_s
      assert_equal "(80, '.')", model.processor.source
      assert_equal [80, "."], model.processor.args
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"

      parser = Fmt::ArgsParser.new(source)
      model = parser.parse

      expected = <<~AST
        (args
          (tokens
            (lparen "(")
            (int "20")
            (comma ",")
            (sp " ")
            (label "omission:")
            (sp " ")
            (tstring-beg "'")
            (tstring-content "&hellip;")
            (tstring-end "'")
            (rparen ")")))
      AST

      assert_equal expected.rstrip, model.ast.to_s
      assert_equal "(20, omission: '&hellip;')", model.processor.source
      assert_equal [20], model.processor.args
      assert_equal({omission: "&hellip;"}, model.processor.kwargs)
    end
  end
end
