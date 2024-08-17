# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  class MacroNode < Node
    # Constructor
    # @rbs children: Array[Node] -- [ProcedureNode?, ArgumentsNode?]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @procedure = children[0]
      @arguments = children[1]
      super(:macro, children, properties)
    end

    attr_reader :procedure # :: ProcedureNode?
    attr_reader :arguments # :: ArgumentsNode?
  end
end
