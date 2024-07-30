# frozen_string_literal: true

require "date"
require "set"
require_relative "filter_group"

module Fmt
  class NativeFilterGroup < FilterGroup
    def initialize
      super

      method_names = supported_method_names(
        Array,
        Binding,
        Class,
        Date,
        DateTime,
        FalseClass,
        Float,
        Hash,
        Integer,
        Method,
        Module,
        NilClass,
        Object,
        Proc,
        Range,
        Set,
        StandardError,
        String,
        Struct,
        Symbol,
        Time,
        TrueClass,
        UnboundMethod
      )

      method_names.each do |method_name|
        add method_name, ->(obj) { obj.public_send method_name }
      end
    end
  end
end
