# frozen_string_literal: true

require "monitor"
require_relative "fmt/cache"
require_relative "fmt/pattern"
require_relative "fmt/sigils"
require_relative "fmt/version"
require_relative "fmt/registries/native_registry"
require_relative "fmt/registries/rainbow_registry"
require_relative "fmt/parsers/template_parser"
# require_relative "fmt/formatter"

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
