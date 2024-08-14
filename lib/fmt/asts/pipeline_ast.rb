# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class PipelineAST < AST::Node
    include Composable

    # Constructor
    # @rbs components: Array[Fmt::MacroAST]
    # @rbs properties: Hash[Symbol, Object]
    # @rbs return: Fmt::PipelineAST
    def initialize(*components, **properties)
      assemble(*components, **properties)
      super(:pipeline, macros, properties)
    end

    # @rbs return: Array[Fmt::MacroAST]
    def macros
      @macros ||= components.select { |c| Fmt::MacroAST === c }
    end

    private

    def subtree
      case macros
      in [Fmt::MacroAST, *] then [AST::Node.new(:macros, macros)]
      else []
      end
    end
  end
end
