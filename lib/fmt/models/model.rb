# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Superclass for all models
  # @note Models are constructed from AST nodes
  class Model
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin
    include Matchable

    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @ast = ast
      @urtext = ast.urtext
      @source = ast.source
      process ast
    end

    attr_reader :ast    # :: Node
    attr_reader :urtext # :: String -- original source code
    attr_reader :source # :: String -- parsed source code

    alias_method :to_s, :source # :: String -- alias for source

    # Model inspection
    # @rbs return: String
    def inspect
      "#<#{self.class.name} #{inspect_properties}>"
    end

    # Hash representation of the model (required for pattern matching)
    # @note Subclasses should override this method and call: super.merge(**)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        urtext: urtext,
        source: source
      }
    end

    private

    # Hash of instance variables for inspection
    # @rbs return: Hash[String, Object]
    def inspectable_properties
      instance_variables.each_with_object({}) do |name, memo|
        value = instance_variable_get(name)
        next if value in Node
        memo[name[1..]] = value
      end
    end

    # String of inspectable properties for inspection
    # @rbs return: String
    def inspect_properties
      inspectable_properties.map { "#{_1}=#{_2.inspect}" }.join " "
    end
  end
end
