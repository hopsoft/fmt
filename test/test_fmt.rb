# frozen_string_literal: true

require "date"
require "rainbow"
require "test_helper"
require_relative "../lib/fmt"

class TestFmt < Minitest::Test
  def setup
    Fmt.add_filter(:repeat80) { |str| str * 80 }
  end

  def test_that_it_has_a_version_number
    refute_nil ::Fmt::VERSION
  end

  def test_format_one
    template = "Hello %{name}cyan|bold"
    actual = Fmt(template, name: "World")
    # puts actual
    expected = "Hello \e[36m\e[1mWorld\e[0m"
    assert_equal expected, actual
  end

  def test_format_two
    template = "Date: %{date}.10s|magenta"
    actual = Fmt(template, date: DateTime.parse("2024-07-26T01:18:59-06:00"))
    # puts actual
    expected = "Date: \e[35m2024-07-26\e[0m"
    assert_equal expected, actual
  end

  def test_format_three
    template = <<~TEMPLATE
      %{head}repeat80|faint
      %{name}upcase|red|bold is %{age}#B|yellow years old in binary!
      %{tail}repeat80|faint
    TEMPLATE

    actual = Fmt(template, head: "-", name: "the parthenon", age: 2_470, tail: "-")
    # puts actual

    expected = <<~RESULT
      \e[2m--------------------------------------------------------------------------------\e[0m
      \e[31m\e[1mTHE PARTHENON\e[0m is \e[33m0B100110100110\e[0m years old in binary!
      \e[2m--------------------------------------------------------------------------------\e[0m
    RESULT

    assert_equal expected, actual
  end

  def test_format_four
    template = <<~TEMPLATE
      %{head}repeat80|faint
      Date: %{date}.10s|reverse|red|bold|underline

      Greetings, %{name}upcase|green|bold

      %{message}strip|bold

      %{redacted}cross_out|faint
      %{head}repeat80|faint
    TEMPLATE

    actual = Fmt(template,
      head: "-",
      date: DateTime.parse("2024-07-26T01:18:59-06:00"),
      name: "Hopsoft",
      message: "This is neat!     ",
      redacted: "This is redacted!",
      tail: "-")
    puts actual

    expected = <<~RESULT
      \e[2m--------------------------------------------------------------------------------\e[0m
      Date: \e[31m\e[1m\e[4m62-70-4202\e[0m

      Greetings, \e[32m\e[1mHOPSOFT\e[0m

      \e[1mThis is neat!\e[0m

      \e[9m\e[2mThis is redacted!\e[0m
      \e[2m--------------------------------------------------------------------------------\e[0m
    RESULT

    assert_equal expected, actual
  end
end
