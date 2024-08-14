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
  #   ProcedureParser.new(p).parse #=> Fmt::ProcedureAST
  #
  class ProcedureParser < Parser
    FILENAME_REGEX = /lib\/fmt\/.*/
    private_constant :FILENAME_REGEX

    # Constructor
    # @rbs callable: Proc -- the Proc to parse
    # @rbs return: Fmt::ProcedureParser
    def initialize(callable)
      @callable = callable
    end

    # @rbs return: Proc
    attr_reader :callable

    protected

    # Parses the proc (Proc)
    # @rbs return: Fmt::ProcedureAST
    def perform
      @ast ||= cache(name || callable.hash) do
        ProcedureAST.new AST::Node.new(:name, [name]), urtext: name&.to_s, source: name&.to_s
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
