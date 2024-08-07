# frozen_string_literal: true

require_relative "test_helper"

class TestCache < UnitTest
  def before_setup
    Fmt::Cache.clear
  end

  def after_teardown
    Fmt::Cache.clear
    Fmt::Cache.reset_capacity
  end

  def test_capacity
    Fmt::Cache.capacity = 10

    20.times { |i| Fmt::Cache[:"key_#{i}"] = i }
    assert_equal 10, Fmt::Cache.size

    Fmt::Cache.clear
    assert_equal 0, Fmt::Cache.size
  end
end
