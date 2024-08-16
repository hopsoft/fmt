# frozen_string_literal: true

module Fmt
  # Ruby source code token extractor
  #
  # Uses Ripper from Ruby's standard library
  # @see https://rubyapi.org/3.4/o/ripper
  # @see doc/RIPPER.md (cheetsheet)
  #
  # @example Ripper token
  #   [[lineno, column], type, token, state]
  #
  class Tokenizer
    # Constructor
    def initialize(...)
      @tokens = []
    end

    attr_reader :tokens # :: Array[Object] -- result of tokenization

    protected

    # Indicates if the Ripper token begins a Regexp literal
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def regexp_start?(token)
      case token
      in [_, :on_regexp_beg, _, _] then true
      else false
      end
    end

    # Indicates if the Ripper token finishes a Regexp literal
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def regexp_finish?(token)
      case token
      in [_, :on_regexp_end, _, _] then true
      else false
      end
    end
  end
end
