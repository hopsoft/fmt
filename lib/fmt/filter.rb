# frozen_string_literal: true

module Fmt
  class Filter
    def initialize(name, value)
      raise ArgumentError, "value must be a String or Proc" unless value.is_a?(String) || value.is_a?(Proc)
      @name = name
      @value = value
    end

    attr_reader :name, :value

    def apply(string)
      case value
      when String then sprintf("%#{filter.value}", string)
      when Proc then filter.value.call(string)
      end
    end

    def string?
      value.is_a? String
    end

    def proc?
      value.is_a? Proc
    end

    def inspect
      "#<#{self.class.name} name=#{name.inspect} value=#{value.inspect}>"
    end
  end
end
