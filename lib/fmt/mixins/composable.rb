# frozen_string_literal: true

module Fmt
  module Composable
    include Enumerable

    def initialize(type, children = [], properties = {})
      assemble properties
      super(type, children.compact, properties)
    end

    private

    # Assigns properties to the receiver
    # @rbs properties: Hash[Symbol, Object] -- exposed as instance methods
    def assemble(properties)
      properties.each do |key, val|
        next if singleton_class.public_instance_methods(false).include?(key)
        singleton_class.define_method(key) { val }
      end
    end
  end
end
