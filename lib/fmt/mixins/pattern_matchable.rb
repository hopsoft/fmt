# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  module PatternMatchable
    def to_h
      raise NotImplementedError, "Must be implemented by including class"
    end

    # Returns a Hash representation of the object limited to the given keys
    # @rbs keys: Array[Symbol] -- keys to include
    # @rbs return: Hash[Symbol, Object]
    def deconstruct_keys(keys = [])
      to_h.select { |key, _| keys&.include? key }
    end

    # Returns an Array representation of the object
    # @rbs return: Array[Object]
    def deconstruct
      to_h.values
    end
  end
end
