# frozen_string_literal: true

require_relative "../asts/proc_ast"
require_relative "parser"

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

      @model = Cache.fetch(cache_key) do
        ProcAST.new(key, filename: filename, lineno: lineno)
      end
    end

    private

    # Registry key for the Proc
    # @rbs return: Symbol
    def key
      Fmt.registry.key_for block
    end

    # Cache key for the Proc
    # @rbs return: String
    def cache_key
      key || block.hash
    end

    # Full path to the file where the Proc is defined
    # @return [String]
    def filename
      path = block.source_location[0]
      path = path.match(FILENAME_REGEX).to_s if path.match?(FILENAME_REGEX)
      path
    end

    # Line number where the Proc begins in filename
    # @rbs return: Integer
    def lineno
      block.source_location[1]
    end
  end
end
