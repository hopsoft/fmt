# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class StubAST < AST::Node
    # Constructor
    # @rbs type: Symbol -- ast type
    # @rbs return: Fmt::StubAST
    def initialize(type)
      super
    end

    attr_reader :source # :: nil
  end
end
