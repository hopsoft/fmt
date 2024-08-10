# frozen_string_literal: true

# rbs_inline: enabled

require "ast"

module Fmt
  # @see https://github.com/whitequark/ast
  class Processor
    # @see http://whitequark.github.io/ast/AST/Processor/Mixin.html
    include AST::Processor::Mixin

    # Assigns node properties to the processor
    # @rbs from: AST::Node -- node to assign properties from
    # @rbs return: void
    def assign_properties(from:)
      from.instance_variables.each do |name|
        case name
        when :@children, :@type, :@hash then next
        else
          value = from.instance_variable_get(name)
          instance_variable_set name, value
          singleton_class.attr_reader name[1..].to_sym
        end
      end
    end
  end
end
