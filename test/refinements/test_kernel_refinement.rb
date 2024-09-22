# frozen_string_literal: true

# rbs_inline: enabled

require "test_helper"

class TestKernelRefinement < Minitest::Test
  using Fmt::KernelRefinement

  def test_fmt
    assert_equal "\e[1mHello, World!\e[0m", fmt("Hello, World!", :bold)
    assert_equal "\e[4mhello\e[0m", fmt(:hello, :underline)

    actual = fmt(Object.new, :red)
    assert actual.start_with?("\e[31m")
    assert actual.end_with?("\e[0m")
  end

  def test_fmt_print
    assert_output("\e[3mHello, World!\e[0m") { fmt_print("Hello, World!", :italic) }
    assert_output("\e[32mhello\e[0m") { fmt_print(:hello, :green) }

    actual = fmt(Object.new, :orange)
    assert actual.start_with?("\e[38;5;214m")
    assert actual.end_with?("\e[0m")
  end

  def test_fmt_puts
    assert_output("\e[1m\e[4mHello, World!\e[0m\n") { fmt_puts("Hello, World!", :bold, :underline) }
    assert_output("\e[35mhello\e[0m\n") { fmt_puts(:hello, :magenta) }

    actual = fmt(Object.new, :yellow)
    assert actual.start_with?("\e[33m")
    assert actual.end_with?("\e[0m")
  end
end
