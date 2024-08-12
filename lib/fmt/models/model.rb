# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Model
    def to_h
      raise NotImplementedError, "Must be implemented by subclass"
    end

    # Returns a Hash representation of the model limited to the given keys
    # @rbs keys: Array[Symbol] -- keys to include
    # @rbs return: Hash[Symbol, Object]
    def deconstruct_keys(keys = [])
      to_h.select { |key, _| keys&.include? key }
    end
  end
end
