# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Model
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin
    include Matchable

    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @ast = ast
      @urtext = ast.urtext
      @source = ast.source
      process ast
    end

    attr_reader :ast    # :: Node
    attr_reader :urtext # :: String -- original source code
    attr_reader :source # :: String -- parsed source code

    # Hash representation of the model (required for pattern matching)
    # @note Subclasses should override this method and call: super.merge(**)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        ast: {
          node: ast,
          deflated: ast.to_s(squish: true)
        },
        urtext: urtext,
        source: source
      }
    end
  end
end
