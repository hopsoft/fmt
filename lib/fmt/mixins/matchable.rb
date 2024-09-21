# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  module Matchable
    # Hash representation of the Object (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      raise Error, "to_h must be implemented by including class"
    end

    # Returns a Hash representation of the object limited to the given keys
    # @rbs keys: Array[Symbol] -- keys to include
    # @rbs return: Hash[Symbol, Object]
    def deconstruct_keys(keys = [])
      to_h.select { _1 in keys }
    end

    # Returns an Array representation of the object
    # @rbs return: Array[Object]
    def deconstruct
      to_h.values
    end
  end
end
