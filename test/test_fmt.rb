# frozen_string_literal: true

require "test_helper"

Fmt.add_rainbow_filters

class TestFmt < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Fmt::VERSION
  end

  def test_format_one
    template = "Hello %{name}cyan|bold"
    actual = Fmt(template, name: "World")
    expected = "Hello \e[36m\e[1mWorld\e[0m"
    # puts actual
    assert_equal expected, actual
  end

  def test_format_two
    template = "Date: %{date}.10s|magenta"
    actual = Fmt(template, date: DateTime.parse("2024-07-26T01:18:59-06:00"))
    expected = "Date: \e[35m2024-07-26\e[0m"
    # puts actual
    assert_equal expected, actual
  end

  def test_format_three
    Fmt.add_filter(:ljust) { |obj| "".ljust 80, obj.to_s }

    template = <<~TEMPLATE
      %{prefix}ljust|faint
      %{name}upcase|red|bold is %{age}#B|yellow years old in binary!
      %{suffix}ljust|faint
    TEMPLATE

    actual = Fmt(template, prefix: "-", name: "the parthenon", age: 2_470, suffix: "-")

    expected = <<~RESULT
      \e[2m--------------------------------------------------------------------------------\e[0m
      \e[31m\e[1mTHE PARTHENON\e[0m is \e[33m0B100110100110\e[0m years old in binary!
      \e[2m--------------------------------------------------------------------------------\e[0m
    RESULT

    # puts actual
    assert_equal expected, actual
  end

  def test_format_four
    Fmt.add_filter(:ljust) { |val| "".ljust 80, val.to_s }

    template = <<~TEMPLATE
      %{prefix}ljust|faint
      Date: %{date}.10s|reverse|red|bold|underline

      Greetings, %{name}upcase|green|bold

      %{message}strip|bold

      %{redacted}cross_out|faint
      %{suffix}ljust|faint
    TEMPLATE

    actual = Fmt(template,
      prefix: "-",
      date: DateTime.parse("2024-07-26T01:18:59-06:00"),
      name: "Hopsoft",
      message: "This is neat!     ",
      redacted: "This is redacted!",
      suffix: "-")

    expected = <<~RESULT
      \e[2m--------------------------------------------------------------------------------\e[0m
      Date: \e[31m\e[1m\e[4m62-70-4202\e[0m

      Greetings, \e[32m\e[1mHOPSOFT\e[0m

      \e[1mThis is neat!\e[0m

      \e[9m\e[2mThis is redacted!\e[0m
      \e[2m--------------------------------------------------------------------------------\e[0m
    RESULT

    # puts actual
    assert_equal expected, actual
  end

  def test_embed
    template = "%{value}lime {{%{embed_value}red|bold|underline}}"
    actual = Fmt(template, value: "Outer", embed_value: "Inner")
    expected = "\e[38;5;46mOuter\e[0m \e[31m\e[1m\e[4mInner\e[0m"
    # puts actual
    assert_equal expected, actual
  end

  def test_deep_embeds
    Fmt.add_filter(:ljust) { |obj| "".ljust 80, obj.to_s }

    template = <<~TEMPLATE
      %{value}yellow|bold
      %{char}ljust|yellow|faint
        {{
        %{embed_value}green|bold
        %{char}ljust|green|faint
          {{
            %{char}ljust|red|faint
            %{deep_embed_value}red|bold
            %{char}ljust|red|faint
          }}
        %{char}ljust|green|faint
        }}
      %{char}ljust|yellow|faint
    TEMPLATE

    actual = Fmt(template, value: "Outer", embed_value: "Inner", deep_embed_value: "Deep", char: "-")

    expected = "\e[33m\e[1mOuter\e[0m\n\e[33m\e[2m--------------------------------------------------------------------------------\e[0m\n  \n  \e[32m\e[1mInner\e[0m\n  \e[32m\e[2m--------------------------------------------------------------------------------\e[0m\n    \n      \e[31m\e[2m--------------------------------------------------------------------------------\e[0m\n      \e[31m\e[1mDeep\e[0m\n      \e[31m\e[2m--------------------------------------------------------------------------------\e[0m\n    \n  \e[32m\e[2m--------------------------------------------------------------------------------\e[0m\n  \n\e[33m\e[2m--------------------------------------------------------------------------------\e[0m\n"

    # puts actual
    assert_equal expected, actual
  end
end
