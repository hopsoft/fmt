# frozen_string_literal: true

# rbs_inline: enabled

require "ast"

module Fmt
  # @see https://github.com/whitequark/ast
  class Processor
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin

    # Indicates if the value is a composite type (Array or Hash)
    # @rbs value: Object -- value to check
    # @rbs return: bool
    def composite?(value)
      value.is_a?(Array) || value.is_a?(Hash)
    end
  end
end
