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
      code = urtext
      code = "#{Sigils::FORMAT_METHOD}('#{urtext}')" if native_format_string?(urtext)

      tokens = tokenize(code)
      method = tokens.find(&:method_name?)&.value&.to_sym

      arguments_tokens = case arguments?(tokens)
      in false then []
      else
        arguments_start = tokens.index(tokens.find(&:arguments_start?)).to_i
        arguments_finish = tokens.index(tokens.find(&:arguments_finish?)).to_i
        tokens[arguments_start..arguments_finish]
      end

      {method: method, arguments_tokens: arguments_tokens}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs method: Symbol?
    # @rbs arguments_tokens: Array[Token] -- arguments tokens
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(method:, arguments_tokens:)
      method = Node.new(:name, [method], urtext: urtext, source: method)
      arguments = ArgumentsParser.new(arguments_tokens).parse
      source = "#{method.source}#{arguments.source}"
      children = [method, arguments].reject(&:empty?)

      Node.new :macro, children.reject(&:empty?), urtext: urtext, source: source
    end

    private

    # Tokenizes source code
    # @rbs code: String -- source code to tokenize
    # @rbs return: Array[Token] -- wrapped ripper tokens
    def tokenize(code)
      tokens = Tokenizer.new(code).tokenize
      macro = []

      tokens.each do |token|
        break if token.whitespace? && macro_finished?(macro)
        macro << token
      end

      macro
    end

    # Indicates if there is a set of arguments in the tokens
    # @rbs tokens: Array[Token] -- tokens to check
    # @rbs return: bool
    def arguments?(tokens)
      arguments_started?(tokens) && arguments_finished?(tokens)
    end

    # Indicates if arguments have started
    # @rbs tokens: Array[Token] -- tokens to check
    # @rbs return: bool
    def arguments_started?(tokens)
      tokens.any? { _1.arguments_start? }
    end

    # Indicates if arguments have finished
    # @note Call this after a whitespace has been detected
    # @rbs tokens: Array[Token] -- tokens to check
    # @rbs return: bool
    def arguments_finished?(tokens)
      tokens.any? { _1.arguments_finish? }
    end

    # Indicates if a macro token array is complete or finished
    # @note Call this after a whitespace has been detected
    # @rbs tokens: Array[Token] -- tokens to check
    # @rbs return: bool
    def finished?(tokens)
      return false unless tokens.any? { _1.method_name? }
      return false if arguments_started?(tokens) && !arguments_finished?(tokens)
      true
    end

    # Indicates if a value is a Ruby native format string
    # @rbs value: String -- value to check
    # @rbs return: bool
    def native_format_string?(value)
      value.start_with? Sigils::FORMAT_PREFIX
    end
  end
end
