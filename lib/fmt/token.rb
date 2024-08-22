# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Convenience wrapper for Ripper tokens
  #
  # @see https://rubyapi.org/3.4/o/ripper
  # @see doc/RIPPER.md (cheetsheet)
  #
  # @example Ripper Token
  #   [[lineno, column], type, token, state]
  #   [[Integer, Integer], Symbol, String, Object]
  #
  class Token
    include Matchable

    # Constructor
    # @rbs ripper_token: Array[[Integer, Integer], Symbol, String, Object] -- Ripper token
    def initialize(ripper_token)
      (lineno, column), type, token, state = ripper_token
      @ripper_token = ripper_token
      @lineno = lineno
      @column = column
      @type = type.to_s.delete_prefix("on_").to_sym # strip Ripper's "on_" prefix for parser semantics
      @token = token
      @state = state
      freeze
    end

    attr_reader :ripper_token # :: Array[[Integer, Integer], Symbol, String, Object]
    attr_reader :lineno       # :: Integer
    attr_reader :column       # :: Integer
    attr_reader :type         # :: Symbol
    attr_reader :token        # :: String
    attr_reader :state        # :: Object

    # @note The entire data structure is considered a "token"
    #       Alias the embedded "token" as "value" to reduce confusion
    alias_method :value, :token

    # Returns a Hash representation of the token
    # @rbs return: Hash[Symbol, Object]
    def to_h
      {
        lineno: lineno,
        column: column,
        type: type,
        token: token,
        value: token,
        state: state
      }
    end

    # --------------------------------------------------------------------------
    # @!group Pattern Matching Support
    # --------------------------------------------------------------------------
    alias_method :deconstruct, :ripper_token

    # Returns a Hash representation of the token limited to the given keys
    # @rbs keys: Array[Symbol] -- keys to include
    # @rbs return: Hash[Symbol, Object]
    def deconstruct_keys(keys = [])
      to_h.select { _1 in ^keys }
    end

    # --------------------------------------------------------------------------
    # @!group Helpers
    # --------------------------------------------------------------------------

    # Indicates if the token is a native String format specifier
    # @see Sigils::FORMAT_SPECIFIERS
    # @rbs return: bool
    def specifier?
      identifier? && Sigils::FORMAT_SPECIFIERS.any?(value)
    end

    # Indicates if the token is an identifier (e.g. method name, format specifier, variable name, etc.)
    # @rbs return: bool
    def identifier?
      type == :ident
    end

    # Indicates if the token is a left paren (i.e. start of arguments)
    # @rbs return: bool
    def arguments_start?
      type == :lparen
    end

    # Indicates if the token is a right paren (i.e. end of arguments)
    # @rbs return: bool
    def arguments_finish?
      type == :rparen
    end
  end
end
