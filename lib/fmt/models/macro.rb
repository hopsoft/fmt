# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../parsers/argument_parser"

module Fmt
  class Macro
    def initialize(source)
      raise ArgumentError, "source must be a String" unless source.is_a?(String)
      @source = source
      @block = Fmt.registry.fetch(source, safe: false) { |*args| sprintf("%#{self}", *args) } # TODO: revisit performing

      # TODO: parse arguments
      @arguments = Fmt::ArgumentParser.new(source).parse
    end

    attr_reader :arguments # : Array[Object] -- arguments to be passed the macro
    attr_reader :block # : Proc -- macro proc
    attr_reader :source # : String -- macro source

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
        source: source,
        block: block,
        arguments: arguments
      }
    end

    def ==(other)
      to_h == other&.to_h
    end
  end
end
