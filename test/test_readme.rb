# rbs_inline: enabled

require "test_helper"

module Fmt
  class TestReadme < UnitTest
    def test_e798c3
      assert_equal "Hello world!", Fmt("%s|>capitalize", "hello world!")
      assert_equal "Hello world!", Fmt("%{msg}|>capitalize", msg: "hello world!")
    end

    def test_1707d2
      assert_equal "Hello world!", Fmt("%s|>prepend('Hello ')", "world!")
      assert_equal "Hello world!", Fmt("%{msg}|>prepend('Hello ')", msg: "world!")
    end

    def test_425625
      expected = "HELLO WORLD!...................."
      assert_equal expected, Fmt("%s|>prepend('Hello ')|>ljust(32, '.')|>upcase", "world!")
      assert_equal expected, Fmt("%{msg}|>prepend('Hello ')|>ljust(32, '.')|>upcase", msg: "world!")
    end

    def test_f55ae2
      obj = Object.new
      expected = obj.inspect.partition(":").last.delete_suffix(">")
      actual = Fmt("%p|>partition(/:/)|>last|>delete_suffix('>')", obj)
      assert_equal expected, actual
    end

    def test_19c8ca
      expected = "\e[36m\e[1m\e[4mHello World!\e[0m"
      actual = Fmt("%s|>cyan|>bold|>underline", "Hello World!")
      assert_equal expected, actual
    end

    def test_0dbfcd
      time = Time.new(2024, 9, 21)
      template = "Date: %<date>.10s|>magenta -- %{msg}|>titleize|>bold"
      expected = "Date: \e[35m2024-09-21\e[0m -- \e[1mThis Is Cool\e[0m"
      actual = Fmt(template, date: time, msg: "this is cool")
      assert_equal expected, actual
    end

    def test_efee7a
      template = "%{msg}|>faint {{%{embed}|>bold}}"
      expected = "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m"
      actual = Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
      assert_equal expected, actual
    end

    def test_abb7ea
      template = "%{msg}|>faint {{%{embed}|>bold}}|>underline"
      expected = "\e[2mLook Ma...\e[0m \e[1m\e[4mI'm embedded!\e[0m"
      actual = Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
      assert_equal expected, actual
    end

    def test_79e924
      template = "%{msg}|>faint {{%{embed}|>bold {{%{deep_embed}|>red|>bold}}}}"
      expected = "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m \e[31m\e[1mAnd I'm deeply embedded!\e[0m"
      actual = Fmt(template, msg: "Look Ma...", embed: "I'm embedded!", deep_embed: "And I'm deeply embedded!")
      assert_equal expected, actual
    end

    def test_054526
      template = <<~T
        Multiline:
        %{one}|>red {{
          %{two}|>blue {{
            %{three}|>green
          }}|>bold
        }}
      T

      expected = "Multiline:\n\e[31mRed\e[0m \n  \e[34mBlue\e[0m \e[1m\n    \e[32mGreen\e[0m\n  \e[0m\n\n"
      actual = Fmt(template, one: "Red", two: "Blue", three: "Green")
      assert_equal expected, actual
    end

    def test_2cacce
      Fmt.register([Object, :shuffle]) { |*args, **kwargs| to_s.chars.shuffle.join }
      message = "This don't make no sense."
      refute_equal message, Fmt("%s|>shuffle", message)
    end

    def test_7df4eb
      Fmt.with_overrides([String, :red] => proc { |*args, **kwargs| Rainbow(self).crimson.bold }) do
        expected = "\e[38;5;197m\e[1mThis is customized red!\e[0m"
        actual = Fmt("%s|>red", "This is customized red!")
        assert_equal expected, actual
      end

      expected = "\e[31mThis is original red!\e[0m"
      actual = Fmt("%s|>red", "This is original red!")
      assert_equal expected, actual
    end
  end
end
