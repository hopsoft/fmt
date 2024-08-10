# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcProcessor < Processor
    attr_reader :key   # :: Symbol  -- key for the Proc in the registry
    attr_reader :block # :: Proc? -- Proc from the registry

    def on_proc(node)
      process_all node.children
    end

    def on_key(node)
      @key = node.children.first
      @block = Fmt.registry[key]
    end
  end
end
