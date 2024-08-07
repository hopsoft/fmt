# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../base_scanner"
require_relative "../../filter"

module Fmt
  class TemplateScanner < BaseScanner
    class FilterScanner < BaseScanner
      def initialize(string)
        @value = []
        super
      end

      protected

      # Regexp that matches the tail/end of a filter string
      # @rbs return: Regexp
      def tail
        /[^\s}%]+/
      end

      # 1) Performs the scan
      # 2) Extracts the value
      # 3) Builds the list of Fmt::Filter instances
      # @rbs return: Aray[Fmt::Filter]
      def perform
        value = string_scanner.scan(tail)
        @value = Fmt::Filter.new_list_from_string(value)
      end
    end
  end
end
