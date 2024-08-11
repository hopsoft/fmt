# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestProcModel < UnitTest
    def test_native
      block = Fmt.registry[:capitalize]
      ast = Fmt::ProcParser.new(block).parse
      model = Fmt::ProcModel.new(ast)
      assert_equal :capitalize, model.key
      assert_equal Fmt.registry[:capitalize], model.block
      assert_equal "lib/fmt/registries/native_registry.rb", model.filename
      assert_instance_of Integer, model.lineno
    end

    def test_rainbow
      block = Fmt.registry[:cyan]
      ast = Fmt::ProcParser.new(block).parse
      model = Fmt::ProcModel.new(ast)
      assert_equal :cyan, model.key
      assert_equal Fmt.registry[:cyan], model.block
      assert_equal "lib/fmt/registries/rainbow_registry.rb", model.filename
      assert_instance_of Integer, model.lineno
    end

    def test_custom
      block = proc { |obj| obj.to_s.upcase }

      Fmt.registry.with_overrides(custom: block) do
        ast = Fmt::ProcParser.new(block).parse
        model = Fmt::ProcModel.new(ast)
        assert_equal :custom, model.key
        assert_equal Fmt.registry[:custom], model.block
        assert model.filename.end_with?(File.basename(__FILE__))
        assert_instance_of Integer, model.lineno
      end

      refute Fmt.registry.key?(:custom)
    end
  end
end
