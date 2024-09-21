# frozen_string_literal: true

require "test_helper"

module Fmt
  class TestFmt < UnitTest
    def test_pipeline
      string = "%s|>indent(4)|>ljust(32, '.')|>cyan|>bold"
      assert_equal "\e[36m\e[1m    Test........................\e[0m", Fmt(string, "Test")
    end

    def test_pipeline_named
      string = "%{value}|>indent(4)|>ljust(32, '.')|>cyan|>bold"
      assert_equal "\e[36m\e[1m    Test........................\e[0m", Fmt(string, value: "Test")
    end

    def test_pipeline_named_alt
      string = "%<value>s|>indent(4)|>ljust(32, '.')|>cyan|>bold"
      assert_equal "\e[36m\e[1m    Test........................\e[0m", Fmt(string, value: "Test")
    end

    def test_pipelines
      string = "%s|>red %s|>blue %s|>green"
      assert_equal "\e[31mRed\e[0m \e[34mBlue\e[0m \e[32mGreen\e[0m", Fmt(string, "Red", "Blue", "Green")
    end

    def test_pipelines_named
      string = "%{a}|>red %{b}|>blue %{c}|>green"
      assert_equal "\e[31mRed\e[0m \e[34mBlue\e[0m \e[32mGreen\e[0m", Fmt(string, a: "Red", b: "Blue", c: "Green")
    end

    def test_pipelines_named_alt
      string = "%<a>s|>red %<b>s|>blue %<c>s|>green"
      assert_equal "\e[31mRed\e[0m \e[34mBlue\e[0m \e[32mGreen\e[0m", Fmt(string, a: "Red", b: "Blue", c: "Green")
    end

    def test_embed
      string = "%{outer}|>faint {{%{inner}|>bold}}"
      assert_equal "\e[2mHello\e[0m \e[1mWorld!\e[0m", Fmt(string, outer: "Hello", inner: "World!")
    end

    def test_embed_with_pipeline
      string = "%{outer}|>faint {{%{inner}|>bold}}|>underline"
      assert_equal "\e[2mHello\e[0m \e[1m\e[4mWorld!\e[0m", Fmt(string, outer: "Hello", inner: "World!")
    end

    def test_embeds
      string = "%{a}|>faint {{%{b}|>bold {{%{c}|>red}}}}"
      assert_equal "\e[2mHello\e[0m \e[1mWorld\e[0m \e[31m!!!\e[0m", Fmt(string, a: "Hello", b: "World", c: "!!!")
    end

    def test_embeds_multiline
      string = <<~S
        %{a}|>red {{
          %{b}|>blue {{
            %{c}|>green
          }}
        }}|>bold
      S
      assert_equal "\e[31mRed\e[0m \e[1m\n  \e[34mBlue\e[0m \n    \e[32mGreen\e[0m", Fmt(string, a: "Red", b: "Blue", c: "Green")
    end
  end
end
