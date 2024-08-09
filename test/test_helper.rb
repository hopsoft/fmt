# frozen_string_literal: true

require "bundler/setup"
require "active_support/all"
require "amazing_print"
require "fileutils"
require "fmt"
require "minitest/autorun"
require "minitest/reporters"
require "monitor"
require "pathname"
require "pry-byebug"
require "pry-doc"
require "rainbow"
require "yaml/store"
require_relative "../lib/fmt"

AmazingPrint.pry!
FileUtils.mkdir_p "tmp"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, fail_fast: true, location: true),
  Minitest::Reporters::MeanTimeReporter.new(show_count: 5, show_progress: false, sort_column: :max, previous_runs_filename: "tmp/minitest-report")
]

class UnitTest < Minitest::Test
  include FileUtils
  include MonitorMixin

  ROOT = Pathname.new(File.expand_path(File.join(__dir__, "..")))

  def assert_template(template, **expected)
    assert_equal expected, template.to_h.except(:macros)
  end

  def assert_macro(macro, **expected)
    assert_instance_of Proc, macro.block
    assert_equal expected, macro.to_h.except(:block)
  end

  def save?
    ENV["SAVE"]
  end

  def resave?
    ENV["RESAVE"]
  end

  def save_expected?(expected, actual)
    return false if expected == actual
    save? || resave?
  end

  def assert_saved(actual)
    location = caller_locations(1, 1).first
    expected = find_expected(location: location)
    expected = save_expected(actual, location: location) if save_expected?(expected, actual)

    if expected != actual
      puts Rainbow("\n".ljust(80, ".")).faint
      puts Rainbow("Expected mismatch!").red.bright
      puts Rainbow("#{storage_key(location)} ").orange + Rainbow(storage_path(location)).faint
      puts Rainbow("Try running with:").cyan
      puts Rainbow("SAVE=true").cyan.bright if expected.nil?
      puts Rainbow("RESAVE=true").cyan.bright if expected != actual
      puts
    end

    assert_equal expected, actual
  end

  def save_expected(object, location: caller_locations(1, 1).first)
    key = storage_key(location)
    store = store(location)
    store.transaction { store[key] = object }
  end

  def find_expected(location: caller_locations(1, 1).first)
    key = storage_key(location)
    store = store(location)
    store.transaction { store[key] }
  end

  private

  def store(location)
    @stores ||= {}
    synchronize do
      path = storage_path(location)
      @stores[path] ||= YAML::Store.new(path, true)
    end
  end

  def storage_path(location)
    path = Pathname.new(location.path)
    path = path.sub_ext("").join("expected.yml")
    mkdir_p path.dirname
    path
  end

  def storage_key(location)
    location.base_label
  end
end
