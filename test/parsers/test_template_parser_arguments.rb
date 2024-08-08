# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestCustomTemplates < UnitTest
    def test_native_with_args
      source = "%s|>ljust(80, '.')"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_native_named_with_args
      source = "%{value}prepend('Prefix: ')"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end

    def test_custom_kwargs_with_args_and_kwargs
      source = "%{value}prepend('Prefix: ')|>truncate(length: 80, separator: '.')"
      templates = Fmt::TemplateParser.new(source).parse

      # @see key matching __method__ in: test/__dir__/expected.yml
      assert_saved templates.map(&:to_h)
    end
  end
end
