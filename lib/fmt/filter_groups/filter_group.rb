# frozen_string_literal: true

# rbs_inline: enabled

require "monitor"
require "set"

module Fmt
  class FilterGroup
    include Enumerable
    include MonitorMixin

    def initialize
      super
      @data = {}
    end

    def with_overrides(overrides, &block)
      return yield if overrides.nil? || overrides.empty?

      overrides = overrides.each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = val if val.is_a? Proc
      end

      originals = data.slice(*overrides.keys)
      overrides.each { |key, val| add key, val }

      yield
    ensure
      synchronize do
        overrides&.each { |key, _| data.delete key }
        originals&.each { |key, val| data[key] = val }
      end
    end

    def [](key)
      synchronize { data[key.to_sym] }
    end

    def supported_method_names(*klasses)
      method_names = klasses.each_with_object(Set.new) do |klass, set|
        klass.public_instance_methods.each do |name|
          next if name.to_s.start_with?("_")
          next if klass.public_instance_method(name).parameters.any? { |(type, *)| type == :req }
          set << name
        end
      end
      method_names.to_a.sort
    end

    def add(key, filter_proc = nil, &block)
      raise ArgumentError, "filter_proc and block are mutually exclusive" if filter_proc && block
      raise ArgumentError, "filter_proc must be a Proc" unless block || filter_proc.is_a?(Proc)
      key = key.to_sym
      synchronize { data[key] = Fmt::Filter.new(key, filter_proc || block) }
    end

    def safe_add(key, filter_proc = nil, &block)
      key = key.to_sym
      return if key?(key)
      add(key, filter_proc, &block)
    end

    def delete(key)
      synchronize { data.delete key.to_sym }
    end

    def each(&block)
      synchronize { data.each(&block) }
    end

    def fetch(key, default = nil)
      synchronize { data.fetch key.to_sym, default }
    end

    def key?(key)
      synchronize { data.key? key.to_sym }
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
