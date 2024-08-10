# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcProcessor < Processor
    attr_reader :key # :: Symbol  -- key for the Proc in the registry

    # Returns the Proc associated with the key
    # @note Fmt::ProcProcessor#process must be called before accessing this property
    # @rbs return: Proc?
    def block
      @block ||= Fmt.registry[key]
    end

    def on_proc(node)
      assign_properties from: node
      process_all node.children
    end

    def on_key(node)
      @key = node.children.first
    end
  end
end
