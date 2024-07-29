# frozen_string_literal: true

require "monitor"
require_relative "filter"

module Fmt
  class Filters
    include Enumerable
    include MonitorMixin

    NATIVE_FILTERS = %i[
      capitalize
      chomp
      chop
      downcase
      lstrip
      reverse
      rstrip
      shellescape
      strip
      succ
      swapcase
      undump
      unicode_normalize
      upcase
    ]

    def initialize
      super
      @entries = {}

      NATIVE_FILTERS.each do |name|
        add(name) { |str| str.then(&:"#{name}") }
      end

      if defined? Rainbow
        begin
          Rainbow::Presenter.public_instance_methods(false).each do |name|
            next unless Rainbow::Presenter.public_instance_method(name).arity == 0
            add(name) { |str| Rainbow(str).public_send(name) }
          end

          Rainbow::X11ColorNames::NAMES.keys.each do |name|
            add(name) { |str| Rainbow(str).public_send(name) }
          end
        rescue => error
          puts "Error adding Rainbow filters! #{error.inspect}"
        end
      end
    end

    def each(&block)
      entries.each(&block)
    end

    def add(name, filter = nil, &block)
      raise ArgumentError, "filter and block are mutually exclusive" if filter && block
      raise ArgumentError, "filter must be a Proc" unless block || filter.is_a?(Proc)
      entries[name.to_sym] = Filter.new(name, filter || block)
    end

    alias_method :<<, :add

    def [](name)
      synchronize { entries[name.to_sym] }
    end

    def fetch(name, default = nil)
      synchronize { entries.fetch name.to_sym, default }
    end

    private

    attr_reader :entries
  end
end
