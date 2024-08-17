# frozen_string_literal: true

module Fmt
  # Parser
  #
  # 1) Parses input (Proc) so it can be tokenized
  # 2) Uses a tokenizer to tokenize the parsed value
  # 3) Returns the tokenized AST
  #
  # @example
  #   p = ->(name) { "Hello, #{name}!" }
  #   ProcedureParser.new(p).parse #=> ProcedureNode
  #
  class ProcedureParser < Parser
    # Constructor
    # @rbs callable: Proc
    def initialize(callable)
      @callable = callable if callable in Proc
    end

    attr_reader :callable # :: Proc?

    # Parses the proc (Proc)
    # @rbs return: ProcedureNode
    def parse
      cache(name || callable.hash) do
        # 1) assemble the AST children
        children = []
        children << Node.new(:name, [name]) if name

        # 2) build the parsed source
        #    TODO: consider bringing back the File reader to set urtext and other properties
        urtext = name&.to_s
        source = name&.to_s

        # 3) build the AST
        ProcedureNode.new(*children, urtext: urtext, source: source)
      end
    end

    private

    # Proc name (registry key)
    # @rbs return: Symbol
    def name
      Fmt.registry.key_for callable
    end
  end
end
