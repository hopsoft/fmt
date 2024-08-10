# frozen_string_literal: true

require "monitor"
require_relative "fmt/registries"
require_relative "fmt/models"
require_relative "fmt/parsers"
require_relative "fmt/processors"
require_relative "fmt/tokenizers"
require_relative "fmt/version"

# Extends native Ruby String format specifications
# @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
module Fmt
  LOCK = Monitor.new # :: Monitor
  private_constant :LOCK

  class Error < StandardError; end

  class << self
    def registry
      @registry ||= LOCK.synchronize do
        NativeRegistry.new.merge! RainbowRegistry.new
      end
    end

    def register(...)
      registry.add(...)
    end

    def unregister(...)
      registry.delete(...)
    end

    # def formatter
    # Formatter.instance
    # end

    # def format(...)
    # formatter.format(...)
    # end

    # def filters
    # formatter.filters
    # end
  end
end

# def Fmt(...)
# Fmt.format(...)
# end
