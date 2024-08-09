# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../cache"

module Fmt
  class Parser
    # Creates a parser
    # @rbs source: String -- string being parsed (default: "")
    def initialize(source = "")
      @source = source.to_s
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

    protected

    def node(type, *children, **properties)
      AST::Node.new type, children, properties
    end

    # Peforms parsing
    # @note Subclasses must implement this method and assign @value
    # @rbs return: String?
    def perform
      raise NotImplementedError
    end
  end
end
