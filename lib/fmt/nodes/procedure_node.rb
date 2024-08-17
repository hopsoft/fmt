# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  class ProcedureNode < Node
    # Constructor
    # @rbs children: Array[Node] -- [[:name, *]]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(*children, **properties)
      @name = children[0]
      super(:procedure, children, properties)
    end

    attr_reader :name # :: Node -- (:name, *)
  end
end
