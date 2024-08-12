# frozen_string_literal: true

require "bundler/setup"
require "active_support/all"
require "amazing_print"
require "minitest/autorun"
require "minitest/reporters"
require "pry-byebug"
require "pry-doc"
require "rainbow"
require_relative "../lib/fmt"

AmazingPrint.defaults = {indent: 2, index: false, ruby19_syntax: true}
AmazingPrint.pry!

FileUtils.mkdir_p "tmp"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, fail_fast: true, location: true),
  Minitest::Reporters::MeanTimeReporter.new(show_count: 5, show_progress: false, sort_column: :max, previous_runs_filename: "tmp/minitest-report")
]

class UnitTest < Minitest::Test
end
