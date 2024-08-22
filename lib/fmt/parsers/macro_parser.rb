# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a macro from a string and builds an AST (Abstract Syntax Tree)
  class MacroParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # : String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      tokenizer = Tokenizer.new(urtext)
      tokenizer.tokenize
      token = tokenizer.identifier_tokens.last
      value = token&.value&.to_sym

      method_name = case value
      in Symbol if Fmt.registry.any?(value) then value
      else Sigils::FORMAT_METHOD
      end

      # source code used to tokenize arguments
      code = case method_name
      in Sigils::FORMAT_METHOD then "%s(%%Q[%s%s])" % [method_name, Sigils::FORMAT_PREFIX, urtext]
      else urtext
      end

      {method_name: method_name, code: code}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs method_name: Symbol?
    # @rbs code: String -- code used to tokenize arguments
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(method_name:, code:)
      children = [
        Node.new(:name, [method_name]),
        ArgumentsParser.new(code).parse
      ]

      Node.new :macro, children.reject(&:empty?), urtext: urtext, source: urtext
    end
  end
end
