# frozen_string_literal: true

require_relative "test_helper"

module Fmt
  class TestRenderer < UnitTest
    def test_format
      renderer = build_renderer("%s")
      assert_equal "Test", renderer.render("Test")
    end

    def test_format_pipeline
      renderer = build_renderer("%s|>to_f|>bold")
      assert_equal "\e[1m5.0\e[0m", renderer.render(5)
    end

    def test_pipeline
      renderer = build_renderer("Hello %s|>truncate(10, omission: '?')|>red|>bold|>italic|>underline")
      assert_equal "Hello \e[31m\e[1m\e[3m\e[4mTest\e[0m", renderer.render("Test")
    end
  end
end
