# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Models
    class TestTemplateEmbeds < UnitTest
      def test_peers_and_nested
        source = "%<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}} {{%<five>cyan|>bold}}"
        ast = Fmt::TemplateParser.new(source).parse
        template = Template.new(ast)
        assert_equal Fmt.registry[:red], template.pipeline.macros[0].callable

        assert_pattern {
          template = {
            ast: {
              node: Node,
              deflated: "(template (pipeline (macro (procedure (key :red)))) (embeds (embed (name \"embed_0_0\") (placeholder \"%{embed_0_0}\") (embeds (embed (name \"embed_1_0\") (placeholder \"{{embed_1_0}}\") (embeds (embed (name \"embed_2_0\") (placeholder \"{{embed_2_0}}\")))))) (embed (name \"embed_0_1\") (placeholder \"{{embed_0_1}}\"))))"
            },
            urtext: "%<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}} {{%<five>cyan|>bold}}",
            source: "%<one>red{{embed_0_0}} {{embed_0_1}}",
            pipeline: {
              ast: {
                node: Node,
                deflated: "(pipeline (macro (procedure (key :red))))"
              },
              urtext: "<one>red",
              source: "<one>red",
              macros: [
                {
                  ast: {
                    node: Node,
                    deflated: "(macro (procedure (key :red)))"
                  },
                  urtext: "<one>red",
                  source: "<one>red",
                  key: :red,
                  callable: Proc,
                  args: [],
                  kwargs: {}
                }
              ]
            }
          }
        }
      end
    end
  end
end
