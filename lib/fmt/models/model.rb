# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Model < AST::Node
    def node(type, *children, **properties)
      AST::Node.new type, children, properties
    end

    # @rbs other: Object -- other object
    # @rbs return: bool
    def ==(other)
      to_sexp == other&.to_sexp
    end
  end
end
