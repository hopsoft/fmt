# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../models/argv"
require_relative "lexers/args_lexer"
require_relative "parser"

module Fmt
  class ArgumentParser < Parser
    protected

    # Tokenizes the source string and returns a hash of the tokenized arguments
    # @rbs return: Hash[Symbol, Object]
    def perform
      @value = Cache.fetch(source) do
        lexer = ArgsLexer.new(source)
        lexer.lex
        Argv.new(source, *lexer.args, **lexer.kwargs)
      end
    end
  end
end
