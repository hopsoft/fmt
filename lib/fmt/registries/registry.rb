# frozen_string_literal: true

# rbs_inline: enabled

require "monitor"
require "set"

module Fmt
  # Extends native Ruby String format specifications
  # @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
  class Registry
    include MonitorMixin

    def initialize
      super
      @data = {}
    end

    def [](key)
      synchronize { data[key.to_sym] }
    end

    def supported_method_names(*klasses)
      method_names = klasses.each_with_object(Set.new) do |klass, set|
        klass.public_instance_methods.each do |name|
          next if name.to_s.start_with?("_") || name.to_s.end_with?("!")
          set << name
        end
      end
      method_names.to_a.sort
    end

    def key?(key, safe: true)
      return data.key?(key.to_sym) unless safe
      synchronize { data.key? key.to_sym }
    end

    def keys
      synchronize { data.keys }
    end

    def values
      synchronize { data.values }
    end

    def add(key, overwrite: false, proc: nil, &block)
      key = key.to_sym
      block ||= binding.local_variable_get(:proc)

      return if key?(key) && !overwrite

      synchronize { data[key] = block }
    end

    def delete(key)
      synchronize { data.delete key.to_sym }
    end

    def fetch(key, safe: true, &block)
      return data.fetch(key.to_sym, block) unless safe
      synchronize { data.fetch key.to_sym, block }
    end

    def merge!(other)
      synchronize { data.merge! other.to_h }
      self
    end

    def to_h
      synchronize { data.dup }
    end

    def with_overrides(overrides, &block)
      return yield if overrides.nil? || overrides.empty?

      overrides = overrides.each_with_object({}) do |(key, val), memo|
        memo[key.to_sym] = val if val.is_a? Proc
      end

      originals = data.slice(*overrides.keys)
      overrides.each { |key, val| add key, overwrite: true, proc: val }

      yield
    ensure
      synchronize do
        overrides&.each { |key, _| delete key }
        originals&.each { |key, val| add key, overwrite: true, proc: val }
      end
    end

    protected

    attr_reader :data
  end
end
