# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Model
    # @rbs return: Hash[Symbol, Object]
    def to_h
      raise NotImplementedError, "Must be implemented by subclasses"
    end

    # @rbs other: Object -- other object
    # @rbs return: bool
    def ==(other)
      to_h == other&.to_h
    end
  end
end
