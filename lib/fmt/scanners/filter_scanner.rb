# frozen_string_literal: true

require_relative "base_scanner"

module Fmt
  class FilterScanner < BaseScanner
    DELIMITER = "|"

    def initialize(string, filters:)
      @filters = filters
      super(string)
    end

    def members
      @members ||= []
    end

    protected

    attr_reader :filters

    def perform
      scanner.reset
      @value = scanner.scan(/[^\s%]+/) # <- extract value
      return unless scanner.matched?

      @members = value.split(DELIMITER)&.map do |name|
        filters.fetch name.to_sym, Fmt::Filter.new(name, name)
      end
    end
  end
end
