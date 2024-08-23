# frozen_string_literal: true

require "bundler/setup"

require "active_support/all"
require "amazing_print"
require "minitest/autorun"
require "minitest/cc"
require "minitest/reporters"
require "pry-byebug"
require "pry-doc"
require "rainbow"

AmazingPrint.defaults = {indent: 2, index: false, ruby19_syntax: true}
AmazingPrint.pry!
Minitest::Cc.start
FileUtils.mkdir_p "tmp"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, fail_fast: true, location: true),
  # Minitest::Reporters::SpecReporter.new(color: true, fail_fast: true, location: true),
  Minitest::Reporters::MeanTimeReporter.new(show_count: 1_000, show_progress: false, sort_column: :avg, previous_runs_filename: "tmp/minitest-report")
]

require_relative "../lib/fmt"

module Fmt
  class UnitTest < Minitest::Test
    # Builds a Renderer for a string
    # @rbs string: String -- string to build the renderer for
    # @rbs return: Renderer
    def build_renderer(string)
      ast = TemplateParser.new(string).parse
      template = Template.new(ast)
      Renderer.new template
    end
  end
end
