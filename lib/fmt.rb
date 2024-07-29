# frozen_string_literal: true

require_relative "fmt/version"
require_relative "fmt/formatter"

module Fmt
  class Error < StandardError; end

  class << self
    def formatter
      Formatter.instance
    end

    def filters
      formatter.filters
    end

    def add_rainbow_filters
      formatter.add_rainbow_filters
    end

    def add_filter(...)
      formatter.add_filter(...)
    end
  end
end

def Fmt(...)
  Fmt.formatter.format(...)
end
