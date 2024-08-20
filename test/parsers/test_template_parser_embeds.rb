# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserEmbeds < UnitTest
      def test_peers_and_nested
        source = "%<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}} {{%<five>cyan|>bold}}"
        ast = Fmt::TemplateParser.new(source).parse
        assert_instance_of Node, ast
        assert_equal source, ast.urtext
        assert_equal "%<one>red{{embed_0_0}} {{embed_0_1}}", ast.source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (procedure
                  (key :red))))
            (embeds
              (embed
                (name "embed_0_0")
                (placeholder "{{embed_0_0}}")
                (embeds
                  (embed
                    (name "embed_1_0")
                    (placeholder "{{embed_1_0}}")
                    (embeds
                      (embed
                        (name "embed_2_0")
                        (placeholder "{{embed_2_0}}"))))))
              (embed
                (name "embed_0_1")
                (placeholder "{{embed_0_1}}"))))
        AST

        assert_equal expected.rstrip, ast.to_s

        embeds = ast.find(:embeds)

        assert_equal 2, embeds.size
        assert_equal "%<one>red{{embed_0_0}} {{embed_0_1}}", embeds.source
        assert_equal "{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}}", embeds[0].source
        assert_equal "{{%<five>cyan|>bold}}", embeds[1].source

        embeds = embeds[0].find(:embeds)
        assert_equal 1, embeds.size
        assert_equal "%<two>ljust(80, '.')|>green {{embed_1_0}}", embeds.source
        assert_equal "{{%<three>blue {{%<four>yellow|>underline}}}}", embeds[0].source

        embeds = embeds[0].find(:embeds)
        assert_equal 1, embeds.size
        assert_equal "%<three>blue {{embed_2_0}}", embeds.source
        assert_equal "{{%<four>yellow|>underline}}", embeds[0].source

        assert_nil ast.find(:embeds)[1].find(:embeds)
      end
    end
  end
end
