# frozen_string_literal: true

module Fmt
  class ProcTokenizer < Tokenizer
    # Constructor
    # @rbs lines: Array[String] | Enumerator[String] -- lines of source code to tokenize
    # @rbs key: Symbol -- registry key for the Proc
    # @rbs filename: String -- full path to the file where the Proc is defined
    # @rbs lineno: Integer -- line number where the Proc begins in filename
    # @rbs return: Fmt::ProcTokenizer
    def initialize(*lines, key:, filename:, lineno:)
      super
      @lines = lines
      @key = key
      @filename = filename
      @lineno = lineno
    end

    attr_reader :lines    # :: Array[String] | Enumerator[String]
    attr_reader :key      # :: Symbol
    attr_reader :filename # :: String
    attr_reader :lineno   # :: Integer

    # Tokenizes the lines of source code
    # @rbs return: Array[Object] -- tokens
    def tokenize
      @tokens = catch(:done) do
        identifiers = 0
        beginners = 0
        finishers = 0

        lines.each_with_object([]) do |line, memo|
          Ripper.lex(line).each do |token|
            identifiers += 1 if proc_identifier?(token)
            beginners += 1 if proc_body_begin?(token)

            next unless identifiers.positive? || beginners.positive?
            memo << token

            if proc_body_finish? token
              finishers += 1
              throw :done, memo if finishers == beginners
            end
          end
        end
      end
    end

    # Converts the result of tokenization to an AST
    # @rbs return: AST::Node
    def to_ast
      ast_node :proc, ast_node(:key, key),
        filename: filename,
        lineno: lineno,
        source: tokens_to_source
    end
  end
end
