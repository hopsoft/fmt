# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  class TokenNode < Node
    # Constructor
    # @rbs type: Symbol -- Token type
    # @rbs children: Array[Node] -- [String]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(type, *children, **properties)
      @value = children[0]
      super(type || :invalid, children, properties)
    end

    attr_reader :value # :: String?
  end
end
