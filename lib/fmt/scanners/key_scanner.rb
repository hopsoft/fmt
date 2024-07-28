# frozen_string_literal: true

require_relative "base_scanner"

module Fmt
  class KeyScanner < BaseScanner
    protected

    def perform
      scanner.reset
      scanner.scan_until(%r{%\{}) # <------------------------ advance to start
      @value = scanner.scan(%r{\w+}) if scanner.matched? # <- extract value
      scanner.scan(%r{\}}) # <------------------------------- advance to end
      value
    end
  end
end
