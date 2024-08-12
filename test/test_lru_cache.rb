# frozen_string_literal: true

require_relative "test_helper"

class TestLRUCache < UnitTest
  def before_setup
    @cache = Fmt::LRUCache.new
  end

  def test_capacity
    @cache.capacity = 10

    20.times { |i| @cache[:"key_#{i}"] = i }
    assert_equal 10, @cache.size

    @cache.clear
    assert_equal 0, @cache.size
  end
end
