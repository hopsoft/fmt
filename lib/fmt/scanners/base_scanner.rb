# frozen_string_literal: true

# rbs_inline: enabled

require "forwardable"
require "strscan"

module Fmt
  class BaseScanner
    extend Forwardable

    # Initializes a scanner instance
    # @rbs string: String -- string to scan
    def initialize(string)
      @string_scanner = StringScanner.new(string)
    end

    def_delegators :string_scanner, :string # : String -- string that is being scanned
    attr_reader :value # : Object? -- primary asset resulting from scan

    # Current string that has not been scanned over yet
    # @rbs return: String
    def current_string
      string_scanner.rest
    end

    # Current position of the string scanner
    # @rbs return: Integer
    def current_position
      string_scanner.pos
    end

    # Indicates if scanning has been performed
    # @rbs return: bool
    def performed?
      !!@performed
    end

    # Resets the scanner so it can be reused if needed
    # @rbs return: void
    def reset
      @performed = false
      string_scanner.reset
    end

    # Scans the string and returns the value
    # @note Subclasses must implement the perform method to support scan
    # @rbs return: Object?
    def scan
      return if performed?
      @performed = true
      perform
      value
    end

    protected

    attr_reader :string_scanner # : StringScanner

    # Peforms the scan
    # @note Should set @value and return it
    # @rbs return: Object?
    def perform
      raise NotImplementedError
    end
  end
end
