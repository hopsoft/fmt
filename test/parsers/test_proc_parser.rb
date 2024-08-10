# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestProcParser < UnitTest
    def test_native
      block = Fmt.registry[:capitalize]

      parser = Fmt::ProcParser.new(block)
      model = parser.parse

      expected = <<~AST
        (proc
          (key :capitalize))
      AST
      assert_equal expected.rstrip, model.ast.to_s

      expected = <<~AST
        (tokens
          (lbrace "{")
          (sp " ")
          (op "|")
          (ident "obj")
          (comma ",")
          (sp " ")
          (op "*")
          (ident "args")
          (op "|")
          (sp " ")
          (ident "obj")
          (period ".")
          (ident "public_send")
          (lparen "(")
          (ident "method_name")
          (comma ",")
          (sp " ")
          (op "*")
          (ident "args")
          (rparen ")")
          (sp " ")
          (rbrace "}"))
      AST
      assert_equal expected.rstrip, model.processor.tokens.to_s

      assert_equal :capitalize, model.processor.key
      assert_equal block, model.processor.block
      assert model.processor.filename.end_with?("lib/fmt/registries/native_registry.rb")
      assert_instance_of Integer, model.processor.lineno
      assert_equal "{ |obj, *args| obj.public_send(method_name, *args) }", model.processor.source
      assert_equal "Test", block.call("test")
      assert_equal "Test", model.processor.block.call("test")
    end

    def test_rainbow
      block = Fmt.registry[:magenta]

      parser = Fmt::ProcParser.new(block)
      model = parser.parse

      expected = <<~AST
        (proc
          (key :magenta))
      AST
      assert_equal expected.rstrip, model.ast.to_s

      expected = <<~AST
        (tokens
          (lbrace "{")
          (sp " ")
          (op "|")
          (ident "obj")
          (op "|")
          (sp " ")
          (const "Rainbow")
          (lparen "(")
          (ident "obj")
          (rparen ")")
          (period ".")
          (ident "public_send")
          (sp " ")
          (ident "name")
          (sp " ")
          (rbrace "}"))
      AST
      assert_equal expected.rstrip, model.processor.tokens.to_s

      assert_equal "(proc\n  (key :magenta))", model.ast.to_s
      assert_equal :magenta, model.processor.key
      assert_equal block, model.processor.block
      assert model.processor.filename.end_with?("lib/fmt/registries/rainbow_registry.rb")
      assert_instance_of Integer, model.processor.lineno
      assert_equal "{ |obj| Rainbow(obj).public_send name }", model.processor.source
      assert_equal "\e[35mtest\e[0m", block.call("test")
      assert_equal "\e[35mtest\e[0m", model.processor.block.call("test")
    end

    def test_custom
      block = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: block) do
        parser = Fmt::ProcParser.new(block)
        model = parser.parse

        expected = <<~AST
          (proc
            (key :custom))
        AST
        assert_equal expected.rstrip, model.ast.to_s

        expected = <<~AST
          (tokens
            (ident "proc")
            (sp " ")
            (lbrace "{")
            (sp " ")
            (op "|")
            (ident "obj")
            (op "|")
            (sp " ")
            (ident "obj")
            (period ".")
            (ident "to_s")
            (period ".")
            (ident "upcase")
            (sp " ")
            (rbrace "}"))
        AST
        assert_equal expected.rstrip, model.processor.tokens.to_s

        assert_equal "(proc\n  (key :custom))", model.ast.to_s
        assert Fmt.registry.key?(:custom)
        assert_equal :custom, model.processor.key
        assert_equal block, model.processor.block
        assert_equal __FILE__, model.processor.filename
        assert_instance_of Integer, model.processor.lineno
        assert_equal "proc { |obj| obj.to_s.upcase }", model.processor.source
        assert_equal "TEST", block.call("test")
        assert_equal "TEST", model.processor.block.call("test")
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
