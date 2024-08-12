# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Extends native Ruby String format specifications with native Ruby methods
  # @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
  class NativeRegistry < Registry
    def initialize
      super

      method_names = supported_method_names(
        Array,
        Date,
        DateTime,
        FalseClass,
        Float,
        Hash,
        Integer,
        NilClass,
        Range,
        Set,
        StandardError,
        String,
        Struct,
        Symbol,
        Time,
        TrueClass
      )

      method_names.each do |method_name|
        add(method_name) { |obj, *args| obj.public_send(method_name, *args) }
      end
    end
  end
end
