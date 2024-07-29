# frozen_string_literal: true

require_relative "base_scanner"

module Fmt
  class KeyScanner < BaseScanner
    protected

    def perform
      string_scanner.skip_until(/%[{]/) # <------------------------------ advance to start
      @value = string_scanner.scan(/\w+/) if string_scanner.matched? # <- extract value
      string_scanner.scan(/[}]/) if string_scanner.matched? # <---------- advance to end
    end
  end
end
