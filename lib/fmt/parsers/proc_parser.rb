# frozen_string_literal: true

require_relative "lexers/proc_lexer"
require_relative "parser"

# Parser that converts a Proc into an AST
#
# Uses Ripper from Ruby's standard library
# @see https://rubyapi.org/3.4/o/ripper
#
module Fmt
  class ProcParser < Parser
    # Constructor
    # @rbs block: Proc -- the proc to parse
    # @rbs return: Fmt::ProcParser
    def initialize(block)
      @block = block
    end

    # @rbs return: Proc
    attr_reader :block

    protected

    # Cache key for the Proc
    # @rbs return: String
    def cache_key
      block.source_location.join ":"
    end

    # Tokenizes the Proc
    # @rbs return: Fmt::Procedure
    def perform
      @value = Cache.fetch(cache_key) do
        lexer = ProcLexer.new(block)

        node(:procedure,
          node(:key, Fmt.registry.key_for(block)),
          node(:filename, lexer.filename),
          node(:lineno, lexer.lineno),
          node(:tokens, lexer.lex))
      end
    end
  end
end
