# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Specifier
    def initialize(value)
      raise ArgumentError, "value must be a String or Proc" unless value.is_a?(String) || value.is_a?(Proc)
      @value = value
      @block = Fmt.registry.fetch(value, safe: false) { |*args| sprintf("%#{self}", *args) } # TODO: revisit performing

      # TODO: parse arguments
      @arguments = []
    end

    attr_reader :arguments # : Array[Object] -- arguments to pass to method
    attr_reader :block # : Proc -- specifier proc
    attr_reader :value # : String | Proc -- specifier value

    # TODO: Revisit performing
    ## Calls the specifier method
    ## @rbs context: Object -- context to invoke specifier with (i.e. self)
    ## @rbs args: Array[Object] -- arguments to pass to specifier method
    ## @rbs return: (?) -- value returned by specifier method
    # def perform(context, *args)
    #  context.instance_exec(*args, &method)
    # end

    def to_h
      {
        value: value,
        block: block,
        arguments: arguments
      }
    end

    def ==(other)
      to_h == other&.to_h
    end
  end
end
