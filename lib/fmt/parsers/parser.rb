# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Parser
    attr_reader :model # : Fmt::Model? -- extracted model

    # Invokes perform and returns a model
    # @rbs return: Fmt::Model
    def parse
      perform
      model
    end

    protected

    # Peforms parsing (internal implementation of parse)
    # @note Should assign @model and return it
    # @rbs return: Fmt::Model?
    def perform
      raise NotImplementedError, "Must be implemented by subclass"
    end
  end
end
