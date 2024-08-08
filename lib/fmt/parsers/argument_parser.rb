# frozen_string_literal: true

# rbs_inline: enabled

require "ripper"
require_relative "parser"
require_relative "../models/argv"
require_relative "../cache"

module Fmt
  class ArgumentParser < Parser
    # Tokenizer for argument strings
    # Extracts args and kwargs from the source string
    #
    # Ripper.lex cheatsheet: @see doc/lexer.md
    #
    # @example Ripper Tokens
    #   [[lineno, column], type, token, state]
    #
    class Tokenizer
      # Initializes a ArgumentTokenizer instance
      # @rbs source: String -- source string to tokenize
      # @rbs return: Fmt::ArgumentTokenizer
      def initialize(source)
        @source = source.to_s
        @args = []
        @kwargs = {}
        tokenize
      end

      attr_reader :source # :: String
      attr_reader :args   # :: Array[Object]
      attr_reader :kwargs # :: Hash[Symbol, Object]

      private

      attr_reader :key       # :: Symbol
      attr_reader :composite # :: Array[Object] | Hash[Symbol, Object]

      # Tokenizes the source string (extracts args and kwargs)
      def tokenize
        Ripper.lex(source).each do |lexeme|
          next if skip?(lexeme)

          if primitive? lexeme
            assign_primitive lexeme

          elsif key? lexeme
            new_key lexeme

          elsif composite_start? lexeme
            new_composite lexeme

          elsif composite_end? lexeme
            assign_composite
          end
        end
      end

      # Indicates if the lexeme should be skipped
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: bool
      def skip?(lexeme)
        case lexeme
        in [_, :on_lparen | :on_sp, _, _] then true
        in [_, :on_tstring_beg | :on_tstring_end, _, _] then true
        in [_, :on_embexpr_beg | :on_embexpr_end, _, _] then true
        else false
        end
      end

      # Indicates if the tokenizer is currently working with an ordinal argument
      # @rbs return: bool
      def arg?
        return false if kwarg?
        return false if composite?
        true
      end

      # Indicates if the tokenizer is currently working with a keyword argument
      # @rbs return: bool
      def kwarg?
        return false unless key
        return false if composite?
        true
      end

      # Indicates if the tokenizer is currently working with a composite argument
      # @rbs return: bool
      def composite?
        !!composite
      end

      # Indicates if the lexeme is a supported primitive argument
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: bool
      def primitive?(lexeme)
        case lexeme
        in [_, :on_tstring_content, value, _] then true        # 1) String
        in [_, :on_symbol, value, _] then true                 # 2) Symbol
        in [_, :on_int, value, _] then true                    # 3) Integer
        in [_, :on_kw, value, _] if value == "false" then true # 4) Boolean
        in [_, :on_kw, value, _] if value == "true" then true  # 5) Boolean
        in [_, :on_kw, value, _] if value == "nil" then true   # 6) Nil
        in [_, :on_float, value, _] then true                  # 7) Float
        in [_, :on_rational, value, _] then true               # 8) Rational
        in [_, :on_imaginary, value, _] then true              # 9) Complex
        else false
        end
      end

      # Type casts the lexeme to a supported primitive
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: String | Symbol | Integer | Float | Rational | Complex | bool | nil
      def cast_primitive(lexeme)
        case lexeme
        in [_, :on_tstring_content, value, _] then value            # 1) String
        in [_, :on_symbol, value, _] then value.to_sym              # 2) Symbol
        in [_, :on_int, value, _] then value.to_i                   # 3) Integer
        in [_, :on_kw, value, _] if value == "false" then false     # 4) Boolean
        in [_, :on_kw, value, _] if value == "true" then true       # 5) Boolean
        in [_, :on_kw, value, _] if value == "nil" then nil         # 6) Nil
        in [_, :on_float, value, _] then value.to_f                 # 7) Float
        in [_, :on_rational, value, _] then Rational(value)         # 8) Rational
        in [_, :on_imaginary, value, _] then Complex(0, value.to_f) # 9) Complex
        end
      end

      # Assigns the lexeme to the appropriate location (i.e. args, composite, or kwargs)
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: void
      def assign_primitive(lexeme)
        return args << cast_primitive(lexeme) if arg?
        return kwargs[key] = cast_primitive(lexeme) if kwarg?

        case composite
        when Array then composite << cast_primitive(lexeme)
        when Hash then composite[key] = cast_primitive(lexeme)
        end
      ensure
        @key = nil
      end

      # Indicates if the lexeme is the start of a composite argument (i.e. Array or Hash)
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: bool
      def composite_start?(lexeme)
        case lexeme
        in [_, :on_lbracket | :on_lbrace, _, _] then true
        else false
        end
      end

      # Indicates if the lexeme is the end of a composite argument (i.e. Array or Hash)
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: bool
      def composite_end?(lexeme)
        case lexeme
        in [_, :on_rbracket | :on_rbrace, _, _] then true
        else false
        end
      end

      # Creates a new composite argument based on the lexeme (i.e. Array or Hash)
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: Array | Hash | nil
      def new_composite(lexeme)
        case lexeme
        in [_, :on_lbracket, _, _] then @composite = []
        in [_, :on_lbrace, _, _] then @composite = {}
        end
      end

      # Assigns the composite argument to the appropriate location (i.e. args or kwargs)
      # @rbs return: void
      def assign_composite
        args << composite
      ensure
        @composite = nil
      end

      # Indicates if the lexeme is Hash key
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: bool
      def key?(lexeme)
        case lexeme
        in [_, :on_label, _, _] then true
        else false
        end
      end

      # Creates a new Hash key based on the lexeme
      # @rbs lexeme: [[Integer, Integer], Symbol, String, Object] -- lexeme to check
      # @rbs return: Symbol
      def new_key(lexeme)
        case lexeme
        in [_, :on_label, value, _] then @key = value.chop.to_sym
        end
      end
    end

    protected

    # Tokenizes the source string and returns a hash of the tokenized arguments
    # @rbs return: Hash[Symbol, Object]
    def perform
      @value = Cache.fetch(source) do
        tokenizer = Tokenizer.new(source)
        Argv.new(source, *tokenizer.args, **tokenizer.kwargs)
      end
    end
  end
end
