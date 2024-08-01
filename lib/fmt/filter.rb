# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Filter
    DELIMITER = "|"

    def self.new_list_from_string(string)
      return [] unless string
      string.split(DELIMITER)&.map do |name|
        name = name.strip
        Fmt.filters.fetch name, Fmt::Filter.new(name, name)
      end
    end

    def initialize(name, value)
      raise ArgumentError, "value must be a String or Proc" unless value.is_a?(String) || value.is_a?(Proc)
      @name = name
      @value = value
      @value = case value
      when String, Symbol then ->(obj) { sprintf("%#{value}", obj.to_s) } # <- native Ruby String formatting
      when Proc then value # <------------------------------------------------ custom Proc registered via: Fmt.add_filter
      end
    end

    attr_reader :name, :value
    alias_method :method, :value

    def apply(string, context:)
      context.instance_exec(string, &method)
    end

    def inspect
      "#<#{self.class.name} name=#{name.inspect} value=#{value.inspect}>"
    end
  end
end
