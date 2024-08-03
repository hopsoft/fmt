# frozen_string_literal: true

require "active_support/all"
require "amazing_print"
require "fileutils"
require "fmt"
require "minitest/autorun"
require "minitest/reporters"
require "pry-byebug"
require "pry-doc"
require "rainbow"
require_relative "../lib/fmt"

FileUtils.mkdir_p "tmp"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, fail_fast: true, location: true),
  Minitest::Reporters::MeanTimeReporter.new(show_count: 5, show_progress: false, sort_column: :max, previous_runs_filename: "tmp/minitest-report")
]

class UnitTest < Minitest::Test
  def assert_template(template, **expected)
    assert_equal expected, template.to_h.except(:specifiers)
  end

  def assert_specifier(specifier, **expected)
    assert_instance_of Proc, specifier.block
    assert_equal expected, specifier.to_h.except(:block)
  end
end
