# frozen_string_literal: true

require "test_helper"

module Fmt
  class TestFmt < UnitTest
    def test_that_it_has_a_version_number
      refute_nil ::Fmt::VERSION
    end

    def test_format_one
      source = "Hello %{name}cyan|>bold"
      assert_equal "Hello \e[36m\e[1mWorld\e[0m", Fmt(source, name: "World")
    end

    def test_format_two
      source = "Date: %<date>.10s|>magenta"
      actual = Fmt(source, date: DateTime.parse("2024-07-26T01:18:59-06:00"))
      expected = "Date: \e[35m2024-07-26\e[0m"
      assert_equal expected, actual
    end

    def test_format_three
      source = <<~T
        %{prefix}to_s|>ljust(80, '-')|>faint
        %{name}upcase|>red|>bold is %{age}yellow|>bold years old in binary!
        %{suffix}to_s|>ljust(80, '-')|>faint
      T

      actual = Fmt(source, prefix: 1, name: "the parthenon", age: 2_470, suffix: 2)

      expected = <<~RESULT
        \e[2m1-------------------------------------------------------------------------------\e[0m
        \e[31m\e[1mTHE PARTHENON\e[0m is \e[33m\e[1m2470\e[0m years old in binary!
        \e[2m2-------------------------------------------------------------------------------\e[0m
      RESULT

      assert_equal expected, actual
    end

    def test_format_four
      source = <<~T
        %{prefix}to_s|>ljust(80, '-')|>faint
        Date: %<date>.10s|>reverse|>red|>bold|>underline

        Greetings, %{name}upcase|>green|>bold

        %{message}strip|>bold

        %{redacted}cross_out|>faint
        %{suffix}to_s|>ljust(80, '-')|>faint
      T

      actual = Fmt(source,
        prefix: 1,
        date: DateTime.parse("2024-07-26T01:18:59-06:00"),
        name: "Hopsoft",
        message: "This is neat!     ",
        redacted: "This is redacted!",
        suffix: 2)

      expected = <<~RESULT
        \e[2m1-------------------------------------------------------------------------------\e[0m
        Date: \e[31m\e[1m\e[4m62-70-4202\e[0m

        Greetings, \e[32m\e[1mHOPSOFT\e[0m

        \e[1mThis is neat!\e[0m

        \e[9m\e[2mThis is redacted!\e[0m
        \e[2m2-------------------------------------------------------------------------------\e[0m
      RESULT

      assert_equal expected, actual
    end

    def test_embed
      source = "%{outer}lime {{%{inner}red|>bold}}"
      actual = Fmt(source, outer: "Outer", inner: "Inner")
      expected = "\e[38;5;46mOuter\e[0m \e[31m\e[1mInner\e[0m"
      assert_equal expected, actual
    end

    # TODO: get this use case working
    # def test_wrapped_embed
    #   source = "%{outer}lime %{{{%{inner}red|>bold}}}underline"
    #   actual = Fmt(source, outer: "Outer", inner: "Inner")
    #   expected = "\e[38;5;46mOuter\e[0m \e[31m\e[1m\e[4mInner\e[0m"
    #   assert_equal expected, actual
    # end

    # TODO: get this use case working
    # def test_wrapped_embed_alt
    #   source = <<~T
    #     %{outer}lime|underline
    #     %{
    #       {{%{inner}red|bold}}
    #     }italic
    #   T
    #   actual = Fmt(source, outer: "Outer", inner: "Inner")
    #   expected = "\e[38;5;46m\e[4mOuter\e[0m\n\e[31m\e[1m\e[3mInner\e[0m\n"
    #   # puts actual
    #   assert_equal expected, actual
    # end
  end
end
