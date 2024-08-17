# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  # Arguments for a macro (MacroNode)
  class ArgumentsNode < Node
    # Constructor
    # @rbs children: Array[Node] -- [[:tokens, *]]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @tokens = children[0]
      super(:arguments, children, properties)
    end

    attr_reader :tokens # :: Array[TokenNode]
  end
end
