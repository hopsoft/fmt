# frozen_string_literal: true

# rbs_inline: enabled

require "strscan"

module Fmt
  class Parser
    # Creates a parser
    # @rbs source: String -- string being parsed (default: "")
    def initialize(source = "")
      @source = source.to_s
      @scanner = StringScanner.new(source)
    end

    attr_reader :source # : String -- string being parsed
    attr_reader :value # : Object? -- extracted value

    # Parses the string and returns the extracted value
    # @note Subclasses must implement the perform method to support parsing
    # @rbs return: String?
    def parse
      perform
      value
    end

    # Current parse position
    # @rbs return: Integer
    def position
      scanner.pos
    end

    # Unparsed portion of the string
    # @rbs return: String
    def tail
      scanner.rest
    end

    protected

    attr_reader :scanner # : StringScanner

    # Peforms parsing
    # @note Subclasses must implement this method and assign and reutrn @value
    # @rbs return: String?
    def perform
      raise NotImplementedError
    end
  end
end
