# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestArgsParser < UnitTest
    def test_with_positional_args
      source = "ljust(80, '.')"

      parser = Fmt::ArgsParser.new(source)
      processor = Fmt::ArgsProcessor.new

      ast = parser.parse
      processor.process ast

      expected = "(args\n  (tokens\n    (int \"80\")\n    (comma \",\")\n    (sp \" \")\n    (tstring-beg \"'\")\n    (tstring-content \".\")\n    (tstring-end \"'\")))"
      assert_equal expected, ast.to_s

      assert_equal "(80, '.')", processor.source
      assert_equal [80, "."], processor.args
    end

    def test_with_positional_and_keyword_args
      source = "truncate(20, omission: '&hellip;')"

      parser = Fmt::ArgsParser.new(source)
      processor = Fmt::ArgsProcessor.new

      ast = parser.parse
      processor.process ast

      expected = "(args\n  (tokens\n    (int \"20\")\n    (comma \",\")\n    (sp \" \")\n    (label \"omission:\")\n    (sp \" \")\n    (tstring-beg \"'\")\n    (tstring-content \"&hellip;\")\n    (tstring-end \"'\")))"
      assert_equal expected, ast.to_s

      assert_equal [20], processor.args
      assert_equal({omission: "&hellip;"}, processor.kwargs)
    end
  end
end
