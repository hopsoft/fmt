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
        assert_equal source, ast.source

        # first level embeds
        assert_equal 2, ast.find(:embeds).size
        assert_equal "%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}", ast.find(:embeds)[0].urtext
        assert_equal "%<two>ljust(80, '.')|>green {{%<three>blue {{%<four>yellow|>underline}}}}", ast.find(:embeds)[0].source
        assert_equal "%<five>cyan|>bold", ast.find(:embeds)[1].source

        # second level embeds (nested)
        assert_equal 1, ast.find(:embeds)[0].find(:embeds).size
        assert_equal "%<three>blue {{%<four>yellow|>underline}}", ast.find(:embeds)[0].find(:embeds)[0].urtext
        assert_equal "%<three>blue {{%<four>yellow|>underline}}", ast.find(:embeds)[0].find(:embeds)[0].source

        # third level embeds (deepest)
        assert_equal 1, ast.find(:embeds)[0].find(:embeds)[0].find(:embeds).size
        assert_equal "%<four>yellow|>underline", ast.find(:embeds)[0].find(:embeds)[0].find(:embeds)[0].urtext
        assert_equal "%<four>yellow|>underline", ast.find(:embeds)[0].find(:embeds)[0].find(:embeds)[0].source

        expected = <<~AST
          (template
            (pipeline
              (macro
                (procedure
                  (key :red))))
            (embeds
              (template
                (pipeline
                  (macro
                    (procedure
                      (key :ljust))
                    (arguments
                      (tokens
                        (lparen "(")
                        (int "80")
                        (comma ",")
                        (sp " ")
                        (tstring-beg "'")
                        (tstring-content ".")
                        (tstring-end "'")
                        (rparen ")"))))
                  (macro
                    (procedure
                      (key :green))))
                (embeds
                  (template
                    (pipeline
                      (macro
                        (procedure
                          (key :blue))))
                    (embeds
                      (template
                        (pipeline
                          (macro
                            (procedure
                              (key :yellow)))
                          (macro
                            (procedure
                              (key :underline)))))))))
              (template
                (pipeline
                  (macro
                    (procedure
                      (key :cyan)))
                  (macro
                    (procedure
                      (key :bold)))))))
        AST

        assert_equal expected.rstrip, ast.to_s
      end
    end
  end
end
