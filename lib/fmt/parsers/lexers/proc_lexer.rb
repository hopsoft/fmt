# frozen_string_literal: true

require "ripper"

module Fmt
  # Source code token extractor for Ruby Procs
  #
  # Uses Ripper from Ruby's standard library
  # @see https://rubyapi.org/3.4/o/ripper
  #
  # Ripper.lex cheatsheet: @see doc/lexer.md
  #
  # @example Ripper Tokens
  #   [[lineno, column], type, token, state]
  #
  class ProcLexer
    FILENAME_REGEX = /lib\/fmt\/.*/
    private_constant :FILENAME_REGEX

    # Constructor
    # @rbs block: Proc -- the proc to lex
    # @rbs return: Fmt::ProcLexer
    def initialize(block)
      @block = block
    end

    attr_reader :block  # :: Proc
    attr_reader :tokens # :: Array

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

    # Lexes the Proc
    # @rbs return: Array[String] -- tokens
    def lex
      @tokens ||= catch(:done) do
        origins = 0
        terminators = 0

        lines.each_with_object([]) do |line, memo|
          Ripper.lex(line).each do |lexeme|
            origins += 1 if origin?(lexeme)
            next unless origins >= 1

            memo.concat extract_tokens(lexeme)

            if terminus? lexeme
              terminators += 1
              throw :done, memo if terminators == origins
            end
          end
        end
      end
    ensure
      close_file
    end

    private

    # Extracts source code tokens from a Ripper lexeme
    #
    # @note Prepends ["proc", " "] if the Proc was defined as a Ruby block
    #       Supports reconstructing the Proc from the AST later if needed
    #
    # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- Ripper lexeme
    # @rbs return: Array[String]
    def extract_tokens(lexeme)
      # rubocop:disable Layout/ExtraSpacing
      case lexeme
      in [_, :on_kw, token, _] if token == "do" then ["proc", " ", token]
      in [_, :on_lbrace, token, _]              then ["proc", " ", token]
      in [_, _, token, _]                       then [token]
      end
      # rubocop:enable Layout/ExtraSpacing
    end

    # Indicates if a Ripper lexeme begins a Proc definition
    # @rbs lexeme: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def origin?(lexeme)
      # rubocop:disable Layout/ExtraSpacing
      case lexeme
      in [_, :on_tlambda, _, _]                        then true
      in [_, :on_const, token, _] if token == "lambda" then true
      in [_, :on_const, token, _] if token == "Proc"   then true
      in [_, :on_const, token, _] if token == "proc"   then true
      in [_, :on_kw, token, _]    if token == "do"     then true
      in [_, :on_lbrace, _, _]                         then true
      else false
      end
      # rubocop:enable Layout/ExtraSpacing
    end

    # Indicates if a Ripper lexeme completes a Proc definition
    # @rbs lexeme: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def terminus?(lexeme)
      # rubocop:disable Layout/ExtraSpacing
      case lexeme
      in [_, :on_kw, token, _ ] if token == "end" then true
      in [_, :on_rbrace, _, _]                    then true
      else false
      end
      # rubocop:enable Layout/ExtraSpacing
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
