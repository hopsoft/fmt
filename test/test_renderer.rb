# frozen_string_literal: true

require_relative "test_helper"

module Fmt
  class TestRenderer < UnitTest
    # def test_format
    #   renderer = build_renderer("%s")
    #   assert_equal "Test", renderer.render("Test")
    # end

    # def test_format_with_prefix_and_suffix
    #   renderer = build_renderer("PREFIX %s SUFFIX")
    #   assert_equal "PREFIX Test SUFFIX", renderer.render("Test")
    # end

    # def test_format_named
    #   renderer = build_renderer("%{value}")
    #   assert_equal "Test", renderer.render(value: "Test")
    # end

    # def test_format_named_with_prefix_and_suffix
    #   renderer = build_renderer("PREFIX %{value} SUFFIX")
    #   assert_equal "PREFIX Test SUFFIX", renderer.render(value: "Test")
    # end

    # def test_format_named_alt
    #   renderer = build_renderer("%<value>s")
    #   assert_equal "Test", renderer.render(value: "Test")
    # end

    # def test_format_named_alt_with_prefix_and_suffix
    #   renderer = build_renderer("PREFIX %<value>s SUFFIX")
    #   assert_equal "PREFIX Test SUFFIX", renderer.render(value: "Test")
    # end

    # def test_format_number
    #   renderer = build_renderer("%.10f")
    #   assert_equal "1.5000000000", renderer.render(1.5)
    # end

    # def test_format_named_number
    #   renderer = build_renderer("%<value>.10f")
    #   assert_equal "1.5000000000", renderer.render(value: 1.5)
    # end

    # def test_format_named_number_with_prefix_and_suffix
    #   renderer = build_renderer("PREFIX %<value>.10f SUFFIX")
    #   assert_equal "PREFIX 1.5000000000 SUFFIX", renderer.render(value: 1.5)
    # end

    # def test_native_pipeline
    #   renderer = build_renderer("%s|>chop")
    #   assert_equal "Tes", renderer.render("Test")
    # end

    # def test_native_pipeline_named
    #   renderer = build_renderer("%{value}|>chop")
    #   assert_equal "Tes", renderer.render(value: "Test")
    # end

    # def test_native_pipeline_named_alt
    #   renderer = build_renderer("%<value>s|>chop")
    #   assert_equal "Tes", renderer.render(value: "Test")
    # end

    # def test_native_pipeline_complex
    #   renderer = build_renderer("%s|>prepend('HEAD ')|><<(' TAIL')|>capitalize|>swapcase|>center(32, '-')")
    #   assert_equal "---------hEAD TEST TAIL---------", renderer.render("Test")
    # end

    # def test_native_pipeline_complex_named
    #   renderer = build_renderer("%{value}|>prepend('HEAD ')|><<(' TAIL')|>capitalize|>swapcase|>center(32, '-')")
    #   assert_equal "---------hEAD TEST TAIL---------", renderer.render(value: "Test")
    # end

    # def test_native_pipeline_complex_named_alt
    #   renderer = build_renderer("%<value>s|>prepend('HEAD ')|><<(' TAIL')|>capitalize|>swapcase|>center(32, '-')")
    #   assert_equal "---------hEAD TEST TAIL---------", renderer.render(value: "Test")
    # end

    # def test_rainbow
    #   renderer = build_renderer("%s|>magenta")
    #   assert_equal "\e[35mTest\e[0m", renderer.render("Test")
    # end

    # def test_rainbow_named
    #   renderer = build_renderer("%{value}magenta")
    #   assert_equal "\e[35mTest\e[0m", renderer.render(value: "Test")
    # end

    # def test_rainbow_named_alt
    #   renderer = build_renderer("%<value>s|>magenta")
    #   assert_equal "\e[35mTest\e[0m", renderer.render(value: "Test")
    # end

    # def test_rainbow_pipeline
    #   renderer = build_renderer("%s|>dodgerblue|>bold|>italic|>underline")
    #   assert_equal "\e[38;5;39m\e[1m\e[3m\e[4mTest\e[0m", renderer.render("Test")
    # end

    # def test_rainbow_pipeline_named
    #   renderer = build_renderer("%{value}dodgerblue|>bold|>italic|>underline")
    #   assert_equal "\e[38;5;39m\e[1m\e[3m\e[4mTest\e[0m", renderer.render(value: "Test")
    # end

    # def test_rainbow_pipeline_named_invlid
    #   renderer = build_renderer("%{value}dodgerblue|>bold|>italic|>underline")
    #   error = assert_raises Fmt::FormatError do
    #     renderer.render("Test")
    #   end
    #   assert_equal 'Did you pass the correct arguments? sprintf("%{value}", "Test") -- Cause: one hash required', error&.message
    # end

    # def test_peers
    #   renderer = build_renderer("%s|>red %s|>green %s|>blue")
    #   assert_equal "\e[31mred\e[0m \e[32mgreen\e[0m \e[34mblue\e[0m", renderer.render("red", "green", "blue")
    # end

    # def test_peers_named
    #   renderer = build_renderer("%{r}red %{g}green %{b}blue")
    #   assert_equal "\e[31mone\e[0m \e[32mtwo\e[0m \e[34mthree\e[0m", renderer.render(r: "one", g: "two", b: "three")
    # end

    # def test_peers_named_alt
    #   renderer = build_renderer("%<r>s|>red %<g>s|>green %<b>s|>blue")
    #   assert_equal "\e[31mone\e[0m \e[32mtwo\e[0m \e[34mthree\e[0m", renderer.render(r: "one", g: "two", b: "three")
    # end

    # def test_peers_complex
    #   renderer = build_renderer("%s|>cyan|>faint Number: %.6f|>center(32, '-')|>bold|>underline %s|>cyan|>faint")
    #   assert_equal "\e[36m\e[2m<\e[0m Number: \e[1m\e[4m-----------123.000000-----------\e[0m \e[36m\e[2m>\e[0m", renderer.render("<", 123, ">")
    # end

    # def test_peers_complex_named
    #   renderer = build_renderer("%{prefix}|>cyan|>faint Number: %<number>.6f|>center(32, '-')|>bold|>underline %{suffix}|>cyan|>faint")
    #   assert_equal "\e[36m\e[2m<\e[0m Number: \e[1m\e[4m-----------123.000000-----------\e[0m \e[36m\e[2m>\e[0m", renderer.render(prefix: "<", number: 123, suffix: ">")
    # end

    def setup
      puts "testing: #{name}"
    end

    def test_embeds
      renderer = build_renderer("%{outer}:{{%{inner}}}")
      assert_equal "outer:inner", renderer.render(outer: "outer", inner: "inner")
    end

    # def test_embeds_deep
    #   renderer = build_renderer("%{a}{{:%{b}{{:%{c}{{:%{d}}}}}}}")
    #   assert_equal "A:B:C:D", renderer.render(a: "A", b: "B", c: "C", d: "D")
    # end

    # def test_embeds_deep_alt
    #   renderer = build_renderer("%<a>s{{:%<b>s{{:%<c>s{{:%<d>s}}}}}}")
    #   assert_equal "A:B:C:D", renderer.render(a: "A", b: "B", c: "C", d: "D")
    # end

    # def test_embeds_deep_multiline
    #   source = <<~STRING
    #     %{a}
    #       {{%{b}
    #         {{%{c}
    #           {{%{d}}}
    #         }}
    #       }}
    #   STRING
    #   renderer = build_renderer(source)
    #   expected = <<~EXPECTED
    #     A
    #       B
    #         C
    #           D
    #   EXPECTED
    #   assert_equal expected.rstrip, renderer.render(a: "A", b: "B", c: "C", d: "D").rstrip
    # end

    # def test_embeds_deep_multiline_with_pipelines
    #   source = <<~STRING
    #     %{a}|>ljust(32, ".")|>mediumslateblue|>bold
    #       {{%{b}|>center(30, "-")|>slateblue|>faint
    #         {{%{c}|>prepend("C: ")|>lime
    #           {{%{d}|>crypt('secret')|>italic|>red}}
    #         }}
    #       }}
    #   STRING
    #   renderer = build_renderer(source)
    #   expected = <<~EXPECTED
    #     \e[38;5;105m\e[1mA...............................\e[0m
    #       \e[38;5;104m\e[2m--------------B---------------\e[0m
    #         \e[38;5;46mC: C\e[0m
    #           \e[3m\e[31mseaRSxjVL4TXI\e[0m
    #   EXPECTED
    #   assert_equal expected.rstrip, renderer.render(a: "A", b: "B", c: "C", d: "D").rstrip
    # end
  end
end
