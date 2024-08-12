# frozen_string_literal: true

module Fmt
  # Parser
  #
  # 1) Parses input (Proc) so it can be tokenized
  # 2) Uses a tokenizer to tokenize the parsed value
  # 3) Returns the tokenized AST
  #
  # @example
  #   prc = proc { |name| "Hello, #{name}!" }
  #   ProcParser.new(prc).parse #=> AST
  #
  class ProcParser < Parser
    FILENAME_REGEX = /lib\/fmt\/.*/
    private_constant :FILENAME_REGEX

    # Constructor
    # @rbs block: Proc -- the Proc to parse
    # @rbs return: Fmt::ProcParser
    def initialize(block)
      @block = block
    end

    # @rbs return: Proc
    attr_reader :block

    protected

    # Parses the block (Proc)
    # @rbs return: Fmt::ProcModel
    def perform
      return ProcAST.stub unless block.is_a?(Proc)

      @model = cache(key || block.hash) do
        key ? ProcAST.new(key) : ProcAST.stub
      end
    end

    private

    # Registry key for the Proc
    # @rbs return: Symbol
    def key
      Fmt.registry.key_for block
    end
  end
end
