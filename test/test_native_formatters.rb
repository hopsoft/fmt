# frozen_string_literal: true

# rbs_inline: enabled

require "test_helper"

module Fmt
  class TestNativeFormatters < UnitTest
    def test_string
      assert_equal "Test", Fmt("%s", "Test")
    end

    def test_integer
      assert_equal "100", Fmt("%d", 100)
    end

    def test_binary
      assert_equal "100", Fmt("%b", 4)
    end

    def test_character
      assert_equal "A", Fmt("%c", 65)
    end

    def test_octal
      assert_equal "20", Fmt("%o", 16)
    end

    def test_hex
      assert_equal "64", Fmt("%x", 100)
    end

    def test_float
      assert_equal "3.141590", Fmt("%f", 3.14159)
    end

    def test_scientific
      assert_equal "3.141590e+00", Fmt("%e", 3.14159)
    end

    def test_inspect
      t = Struct.new(:a, :b, :c).new(:foo, "bar", true)
      assert_equal t.inspect, Fmt("%p", t)
    end

    def test_percent
      assert_equal "100%", Fmt("%d%%", 100)
    end

    def test_string_width
      assert_equal "  Test", Fmt("%6s", "Test")
      assert_equal "Test  ", Fmt("%-6s", "Test")
    end

    def test_integer_width_and_padding
      assert_equal "  100", Fmt("%5d", 100)
      assert_equal "00100", Fmt("%05d", 100)
    end

    def test_binary_width_and_padding
      assert_equal "  100", Fmt("%5b", 4)
      assert_equal "00100", Fmt("%05b", 4)
    end

    def test_octal_width_and_padding
      assert_equal "  20", Fmt("%4o", 16)
      assert_equal "0020", Fmt("%04o", 16)
    end

    def test_hex_width_and_padding
      assert_equal "  64", Fmt("%4x", 100)
      assert_equal "0064", Fmt("%04x", 100)
      assert_equal "  64", Fmt("%4X", 100)
      assert_equal "0064", Fmt("%04X", 100)
    end

    def test_float_precision
      assert_equal "3.14", Fmt("%.2f", 3.14159)
      assert_equal "3.1416", Fmt("%.4f", 3.14159)
    end

    def test_scientific_precision
      assert_equal "3.14e+00", Fmt("%.2e", 3.14159)
      assert_equal "3.1416E+00", Fmt("%.4E", 3.14159)
    end

    def test_inspect_limit
      long_string = "a" * 100
      assert_equal "\"aaaaaaaaaaaaaaaaaaaaaa", Fmt("%.23p", long_string)
    end
  end
end
