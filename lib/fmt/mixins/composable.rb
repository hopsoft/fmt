# frozen_string_literal: true

module Fmt
  module Composable
    attr_reader :components # :: Array[Object]

    protected

    # Assigns components to the receiver
    # @rbs components: Array[Object] -- components to assign
    # @rbs properties: Hash[Symbol, Object] -- exposed as instance methods
    # @rbs return: Array[Object] -- components
    def assemble(*components, **properties)
      @components = components

      properties.each do |key, val|
        next if singleton_class.public_instance_methods(false).include?(key)
        singleton_class.define_method(key) { val }
      end
    end
  end
end
