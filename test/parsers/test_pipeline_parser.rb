# frozen_string_literal: true

require_relative "../test_helper"

class TestPipelineParser < UnitTest
  def test_one
    source = "ljust(80, '.')"
    ast = Fmt::PipelineParser.new(source).parse
    assert_instance_of Fmt::PipelineAST, ast
    assert_equal source, ast.source

    expected = <<~AST
      (pipeline
        (macros
          (macro
            (proc
              (name :ljust))
            (arguments
              (tokens
                (lparen "(")
                (int "80")
                (comma ",")
                (sp " ")
                (tstring-beg "'")
                (tstring-content ".")
                (tstring-end "'")
                (rparen ")"))))))
    AST
    assert_equal expected.rstrip, ast.to_s
  end

  def test_two
    source = "ljust(80, '.')|>cyan"
    ast = Fmt::PipelineParser.new(source).parse
    assert_instance_of Fmt::PipelineAST, ast
    assert_equal source, ast.source

    expected = <<~AST
      (pipeline
        (macros
          (macro
            (proc
              (name :ljust))
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
            (proc
              (name :cyan))
            (arguments
              (tokens)))))
    AST
    assert_equal expected.rstrip, ast.to_s
  end

  def test_multiple
    source = "pluralize(2, locale: :en)|>titleize|>truncate(30, '.')|>red|>bold|>underline"
    ast = Fmt::PipelineParser.new(source).parse
    assert_instance_of Fmt::PipelineAST, ast
    assert_equal source, ast.source

    expected = <<~AST
      (pipeline
        (macros
          (macro
            (proc
              (name :pluralize))
            (arguments
              (tokens
                (lparen "(")
                (int "2")
                (comma ",")
                (sp " ")
                (label "locale:")
                (sp " ")
                (symbeg ":")
                (ident "en")
                (rparen ")"))))
          (macro
            (proc
              (name :titleize))
            (arguments
              (tokens)))
          (macro
            (proc
              (name :truncate))
            (arguments
              (tokens
                (lparen "(")
                (int "30")
                (comma ",")
                (sp " ")
                (tstring-beg "'")
                (tstring-content ".")
                (tstring-end "'")
                (rparen ")"))))
          (macro
            (proc
              (name :red))
            (arguments
              (tokens)))
          (macro
            (proc
              (name :bold))
            (arguments
              (tokens)))
          (macro
            (proc
              (name :underline))
            (arguments
              (tokens)))))
    AST
    assert_equal expected.rstrip, ast.to_s
  end
end
