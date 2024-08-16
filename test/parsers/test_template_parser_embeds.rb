# frozen_string_literal: true

require_relative "../test_helper"

module Fmt
  module Parsers
    class TestTemplateParserEmbeds < UnitTest
      def test_peers_and_nested
        source = "%<one>red{{%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}}} {{%<five>cyan|>bold}}"
        scanner = StringScanner.new(source)
        ast = Fmt::TemplateParser.new(scanner).parse
        assert_instance_of TemplateAST, ast
        assert_equal source, ast.urtext
        # assert_equal source, ast.source # TODO: fix this

        expected = <<~AST
          (template
            (key "one")
            (pipeline
              (macro
                (procedure
                  (name :red))
                (arguments
                  (tokens
                    (lparen "(")
                    (int "80")
                    (comma ",")
                    (sp " ")
                    (tstring-beg "'")
                    (tstring-content ".")
                    (tstring-end "'")
                    (rparen ")")))))
            (embeds
              (embed :embed_0_0
                (embeds
                  (embed :embed_1_0
                    (embeds
                      (embed :embed_2_0)))))
              (embed :embed_0_1)))
        AST

        assert_equal expected.rstrip, ast.to_s

        assert_equal 2, ast.embeds.children.size
        assert_equal "%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}", ast.embeds.children[0].source
        assert_equal "%<three>blue {{%<four>yellow|>underline}}", ast.embeds.children[0].embeds.children[0].source
        assert_equal "%<four>yellow|>underline", ast.embeds.children[0].embeds.children[0].embeds.children[0].source
        assert_equal "%<five>cyan|>bold", ast.embeds.children[1].source
      end
    end
  end
end
