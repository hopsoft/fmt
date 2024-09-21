# frozen_string_literal: true

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
      assert_equal "HELLO WORLD!....................", Fmt("%s|>prepend('Hello ')|>ljust(32, '.')|>upcase", "world!")
      assert_equal "HELLO WORLD!....................", Fmt("%{msg}|>prepend('Hello ')|>ljust(32, '.')|>upcase", msg: "world!")
    end

    def test_f55ae2
      obj = Object.new
      assert_equal "", Fmt("%p|>partition(/:/)|>last|>delete_suffix('>')", obj.object_id.to_s(16))
    end

    def test_19c8ca
      assert_equal "\e[36m\e[1m\e[4mHello World!\e[0m", Fmt("%s|>cyan|>bold|>underline", "Hello World!")
    end

    def test_0dbfcd
      time = Time.new(2024, 9, 21)
      template = "Date: %<date>.10s|>magenta -- %{msg}|>titleize|>bold"
      assert_equal "Date: \e[35m2024-09-21\e[0m \e[1mThis Is Cool\e[0m", Fmt(template, date: time, msg: "this is cool")
    end

    def test_efee7a
      template = "%{msg}|>faint {{%{embed}|>bold}}"
      assert_equal "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m", Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
    end

    def test_abb7ea
      template = "%{msg}|>faint {{%{embed}|>bold}}|>underline"
      assert_equal "\e[2mLook Ma...\e[0m \e[1m\e[4mI'm embedded!\e[0m", Fmt(template, msg: "Look Ma...", embed: "I'm embedded!")
    end

    def test_79e924
      template = "%{msg}|>faint {{%{embed}|>bold {{%{deep_embed}|>red|>bold}}}}"
      assert_equal "\e[2mLook Ma...\e[0m \e[1mI'm embedded!\e[0m \e[31m\e[1mAnd I'm deeply embedded!\e[0m", Fmt(template, msg: "Look Ma...", embed: "I'm embedded!", deep_embed: "And I'm deeply embedded!")
    end

    def test_054526
      template = <<~T
        Multiline:
        %{one}|>red {{
          %{two}|>blue {{
            %{three}|>green
          }}
        }}|>bold
      T

      assert_equal "Multiline:\n\e[31mRed\e[0m \e[1m\n  \e[34mBlue\e[0m \n    \e[32mGreen\e[0m", Fmt(template, one: "Red", two: "Blue", three: "Green")
    end

    def test_2cacce
      Fmt.register([Object, :shuffle]) { |*args, **kwargs| to_s.chars.shuffle.join }
      refute_equal "This don't make no sense.", Fmt("%s|>shuffle", "This don't make no sense.")
    end

    def test_7df4eb
      Fmt.with_overrides([String, :red] => proc { |*args, **kwargs| Rainbow(self).crimson.bold }) do
        assert_equal "\e[38;5;197m\e[1mThis is customized red!\e[0m", Fmt("%s|>red", "This is customized red!")
      end

      assert_equal "\e[31mThis is original red!\e[0m", Fmt("%s|>red", "This is original red!")
    end
  end
end
