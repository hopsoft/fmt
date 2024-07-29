# frozen_string_literal: true

require_relative "base_scanner"

module Fmt
  class FilterScanner < BaseScanner
    DELIMITER = "|"

    def initialize(string, registered_filters:)
      @registered_filters = registered_filters
      @filters = []
      super(string)
    end

    alias_method :filter_string, :value
    attr_reader :filters

    protected

    attr_reader :registered_filters

    def perform
      @value = string_scanner.scan(/[^\s%]+/) # <- extract value
      return unless string_scanner.matched?

      @filters = value.split(DELIMITER)&.map do |name|
        registered_filters.fetch name.to_sym, Fmt::Filter.new(name, name)
      end
    end
  end
end
