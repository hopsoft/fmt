# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserEmbeds < UnitTest
      def test_peers_and_nested
        source = "%<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}} {{%<five>cyan|>bold}}"
        ast = Fmt::TemplateParser.new(source).parse
        assert_instance_of TemplateNode, ast
        assert_equal source, ast.urtext
        assert_equal "%<one>red{{embed_0_0}} {{embed_0_1}}", ast.source

        expected = <<~AST
          (template
            (key "one")
            (pipeline
              (macro
                (procedure
                  (name :red))))
            (embeds
              (embed
                (key :embed_0_0)
                (placeholder "{{embed_0_0}}")
                (embeds
                  (embed
                    (key :embed_1_0)
                    (placeholder "{{embed_1_0}}")
                    (embeds
                      (embed
                        (key :embed_2_0)
                        (placeholder "{{embed_2_0}}") nil)))))
              (embed
                (key :embed_0_1)
                (placeholder "{{embed_0_1}}") nil)))
        AST

        assert_equal expected.rstrip, ast.to_s

        embeds = ast.embeds.select(:embed)
        assert_equal 2, embeds.size
        assert_equal "%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}", embeds[0].source
        assert_equal "%<five>cyan|>bold", embeds[1].source

        embeds = embeds[0].embeds.select(:embed)
        assert_equal 1, embeds.size
        assert_equal "%<three>blue {{%<four>yellow|>underline}}", embeds[0].source

        embeds = embeds[0].embeds.select(:embed)
        assert_equal 1, embeds.size
        assert_equal "%<four>yellow|>underline", embeds[0].source
      end
    end
  end
end
