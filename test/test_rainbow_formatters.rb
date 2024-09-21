# frozen_string_literal: true

# rbs_inline: enabled

require "test_helper"

module Fmt
  class TestRainbowFormatters < UnitTest
    def test_black
      assert_equal "\e[30mTest\e[0m", Fmt("%s|>black", "Test")
    end

    def test_red
      assert_equal "\e[31mTest\e[0m", Fmt("%s|>red", "Test")
    end

    def test_green
      assert_equal "\e[32mTest\e[0m", Fmt("%s|>green", "Test")
    end

    def test_yellow
      assert_equal "\e[33mTest\e[0m", Fmt("%s|>yellow", "Test")
    end

    def test_blue
      assert_equal "\e[34mTest\e[0m", Fmt("%s|>blue", "Test")
    end

    def test_magenta
      assert_equal "\e[35mTest\e[0m", Fmt("%s|>magenta", "Test")
    end

    def test_cyan
      assert_equal "\e[36mTest\e[0m", Fmt("%s|>cyan", "Test")
    end

    def test_white
      assert_equal "\e[37mTest\e[0m", Fmt("%s|>white", "Test")
    end

    def test_bg_black
      assert_equal "\e[40mTest\e[0m", Fmt("%s|>bg(:black)", "Test")
    end

    def test_bg_yellow
      assert_equal "\e[43mTest\e[0m", Fmt("%s|>bg(:yellow)", "Test")
    end

    def test_bright
      assert_equal "\e[1mTest\e[0m", Fmt("%s|>bright", "Test")
    end

    def test_underline
      assert_equal "\e[4mTest\e[0m", Fmt("%s|>underline", "Test")
    end

    def test_blink
      assert_equal "\e[5mTest\e[0m", Fmt("%s|>blink", "Test")
    end

    def test_inverse
      assert_equal "\e[7mTest\e[0m", Fmt("%s|>inverse", "Test")
    end

    def test_hide
      assert_equal "\e[8mTest\e[0m", Fmt("%s|>hide", "Test")
    end

    def test_faint
      assert_equal "\e[2mTest\e[0m", Fmt("%s|>faint", "Test")
    end

    def test_italic
      assert_equal "\e[3mTest\e[0m", Fmt("%s|>italic", "Test")
    end

    def test_cross_out
      assert_equal "\e[9mTest\e[0m", Fmt("%s|>cross_out", "Test")
    end

    def test_rgb_color
      assert_equal "\e[38;5;214mTest\e[0m", Fmt("%s|>color(255,128,0)", "Test")
    end

    def test_hex_color
      assert_equal "\e[38;5;214mTest\e[0m", Fmt("%s|>color('#FF8000')", "Test")
    end
  end
end
