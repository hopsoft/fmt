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

GC.disable
AmazingPrint.defaults = {indent: 2, index: false, ruby19_syntax: true}
AmazingPrint.pry!
Minitest::Cc.start
FileUtils.mkdir_p "tmp"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, fail_fast: true, location: true),
  # Minitest::Reporters::SpecReporter.new(color: true, fail_fast: true, location: true),
  Minitest::Reporters::MeanTimeReporter.new(show_count: 5, show_progress: false, sort_column: :avg, previous_runs_filename: "tmp/minitest-report")
]

require_relative "../lib/fmt"

BENCHMARKS = {}

Minitest.after_run do
  if ENV["BM"]
    BENCHMARKS.keys.sort.reverse_each do |key|
      BENCHMARKS[key].each do |value|
        puts case key
        in 5.. then Rainbow(value).crimson + Rainbow(" (#{key}ms)").crimson.bold
        in 1..5 then Rainbow(value).magenta + Rainbow(" (#{key}ms)").magenta.bold
        else Rainbow(value).cyan + Rainbow(" (#{key}ms)").cyan.bold
        end
      end
    end
  end
end

module Fmt
  class UnitTest < Minitest::Test
    def before_setup
      if ENV["BM"]
        @benchmark_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    def after_teardown
      if ENV["BM"]
        return unless @benchmark_start_time

        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        duration_ms = ((end_time - @benchmark_start_time) * 1000).round(2)

        BENCHMARKS[duration_ms] ||= []
        BENCHMARKS[duration_ms] << "#{BENCHMARKS.values.flatten.size + 1}) #{self.class}##{name}"
      end
    end

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
