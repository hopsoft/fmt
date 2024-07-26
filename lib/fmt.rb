# frozen_string_literal: true

require_relative "fmt/version"
require_relative "fmt/formatter"

module Fmt
  class Error < StandardError; end

  class << self
    def formatter
      Formatter.instance
    end

    def add_filter(...)
      formatter.filters.add(...)
    end
  end
end

def Fmt(...)
  Fmt.formatter.format(...)
end
