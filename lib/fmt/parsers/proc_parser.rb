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
      @model = Cache.fetch(cache_key) do
        tokenizer = ProcTokenizer.new(*lines)
        tokens = tokenizer.tokenize

        ProcModel.new(*tokens, key: key, filename: filename, lineno: lineno)
      end
    ensure
      close_file
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

    # Opens the source file
    # @rbs return: File
    def open_file
      @file ||= File.open(filename, "r")
    end

    # Closes the source file and cleans up resources
    # @rbs return: void
    def close_file
      @file&.close
      remove_instance_variable :@file if instance_variable_defined?(:@file)
    end

    # Lines of source code in filename starting at lineno
    # @note Lazily reads the file line by line starting at lineno
    # @rbs return: Enumerator[String]
    def lines
      open_file.each_line.lazy.drop lineno - 1
    end
  end
end
