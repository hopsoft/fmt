# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Extends native Ruby String format specifications with native Ruby methods
  # @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
  class NativeRegistry < Registry
    SUPPORTED_CLASSES = [
      Array,
      Date,
      DateTime,
      FalseClass,
      Float,
      Hash,
      Integer,
      NilClass,
      Range,
      Regexp,
      Set,
      StandardError,
      String,
      Struct,
      Symbol,
      Time,
      TrueClass
    ].freeze

    # Constructor
    def initialize
      super

      format = ->(*args, **kwargs) do
        verbose = $VERBOSE
        $VERBOSE = nil
        Kernel.sprintf(self, *args, **kwargs)
      ensure
        $VERBOSE = verbose
      end

      add([Kernel, :format], &format)
      add([Kernel, :sprintf], &format)

      SUPPORTED_CLASSES.each do |klass|
        supported_method_names(klass).each do |name|
          add([klass, name]) { |*args, **kwargs| public_send(name, *args, **kwargs) }
        end
      end
    rescue => error
      puts "#{self.class.name} - Error adding filters! #{error.inspect}"
    end

    private

    # Array of supported method names for a Class
    # @rbs klass: Class
    # @rbs return: Array[Symbol]
    def supported_method_names(klass)
      klass.public_instance_methods.each_with_object(Set.new) do |name, memo|
        next if name in Sigils::FORMAT_SPECIFIERS
        next if name.start_with?("_") || name.end_with?("!")
        memo << name
      end
    end
  end
end
