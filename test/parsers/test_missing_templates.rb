# frozen_string_literal: true

require_relative "../test_helper"

module Parsers
  class TestMissingTemplate < Minitest::Test
    def test_missing
      source = "Not a template"
      templates = Fmt::TemplateParser.new(source).parse
      assert_instance_of Array, templates
      assert_empty templates
    end
  end
end
