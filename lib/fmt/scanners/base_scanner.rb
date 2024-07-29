# frozen_string_literal: true

require "forwardable"
require "strscan"

module Fmt
  class BaseScanner
    extend Forwardable

    def initialize(string)
      @string_scanner = StringScanner.new(string)
    end

    def_delegators :string_scanner, :string, :rest
    attr_reader :value

    def performed?
      !!@performed
    end

    def reset
      @performed = false
      string_scanner.reset
    end

    def scan
      return if performed?
      @performed = true
      perform
      value
    end

    protected

    attr_reader :string_scanner

    def perform
      raise NotImplementedError
    end
  end
end
