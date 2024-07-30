# frozen_string_literal: true

require "monitor"
require "set"
require_relative "../filter"

module Fmt
  class FilterGroup
    include Enumerable
    include MonitorMixin

    def initialize
      super
      @data = {}
    end

    def [](name)
      synchronize { data[name.to_sym] }
    end

    def supported_method_names(*klasses)
      method_names = klasses.each_with_object(Set.new) do |klass, set|
        klass.public_instance_methods.each do |method_name|
          next if method_name.to_s.start_with?("_")
          next if klass.public_instance_method(method_name).parameters.any? { |(type, *)| type == :req }
          set << method_name
        end
      end
      method_names.to_a.sort
    end

    def add(name, filter_proc = nil, &block)
      raise ArgumentError, "filter_proc and block are mutually exclusive" if filter_proc && block
      raise ArgumentError, "filter_proc must be a Proc" unless block || filter_proc.is_a?(Proc)
      synchronize do
        data[name.to_sym] = Fmt::Filter.new(name.to_sym, filter_proc || block)
      end
    end

    def safe_add(name, filter_proc = nil, &block)
      return if key?(name)
      add(name, filter_proc, &block)
    end

    def each(&block)
      synchronize { data.each(&block) }
    end

    def fetch(name, default = nil)
      synchronize { data.fetch name.to_sym, default }
    end

    def key?(name)
      synchronize { data.key? name.to_sym }
    end

    alias_method :added?, :key?
    alias_method :include?, :key?

    def merge!(other)
      synchronize { data.merge! other.to_h }
      self
    end

    def to_h
      data.dup
    end

    protected

    attr_reader :data
  end
end
