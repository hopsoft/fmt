# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Extends native Ruby String format specifications with native Ruby methods
  # @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
  class NativeRegistry < Registry
    # Constructor
    def initialize
      super

      formatters = %i[format sprintf]
      formatters.each do |method_name|
        add(method_name) { |*args| public_send(method_name, self, *args) }
      end

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

      method_names << :format
      method_names << :sprintf

      method_names.each do |method_name|
        add(method_name) { |*args| public_send(method_name, *args) }
      end
    rescue => error
      puts "#{self.class.name} - Error adding filters! #{error.inspect}"
    end
  end
end
