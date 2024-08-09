# frozen_string_literal: true

require_relative "test_helper"
require_relative "../lib/fmt/parsers/proc_parser"
require_relative "../lib/fmt/processors/proc_processor"

module Parsers
  class TestProcParser < UnitTest
    def test_native
      block = Fmt.registry[:capitalize]
      ast = Fmt::ProcParser.new(block).parse
      processor = Fmt::ProcProcessor.new
      processor.process ast

      assert_saved ast.to_s
      assert_equal :capitalize, processor.key
      assert_equal block, processor.block
      assert processor.filename.end_with?("lib/fmt/registries/native_registry.rb")
      assert_instance_of Integer, processor.lineno
      assert_equal "proc { |obj, *args| obj.public_send(method_name, *args) }", processor.source
      assert_equal "Test", block.call("test")
      assert_equal "Test", processor.block.call("test")
    end

    def test_rainbow
      block = Fmt.registry[:magenta]
      ast = Fmt::ProcParser.new(block).parse
      processor = Fmt::ProcProcessor.new
      processor.process ast

      assert_saved ast.to_s
      assert_equal :magenta, processor.key
      assert_equal block, processor.block
      assert processor.filename.end_with?("lib/fmt/registries/rainbow_registry.rb")
      assert_instance_of Integer, processor.lineno
      assert_equal "proc { |obj| Rainbow(obj).public_send name }", processor.source
      assert_equal "\e[35mtest\e[0m", block.call("test")
      assert_equal "\e[35mtest\e[0m", processor.block.call("test")
    end

    def test_custom
      block = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: block) do
        ast = Fmt::ProcParser.new(block).parse
        processor = Fmt::ProcProcessor.new
        processor.process ast

        assert_saved ast.to_s
        assert Fmt.registry.key?(:custom)
        assert_equal :custom, processor.key
        assert_equal block, processor.block
        assert_equal __FILE__, processor.filename
        assert_instance_of Integer, processor.lineno
        assert_equal "proc { |obj| obj.to_s.upcase }", processor.source
        assert_equal "TEST", block.call("test")
        assert_equal "TEST", processor.block.call("test")
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
