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

      key = extract_key(tokenizer)
      source = extract_source(key, tokenizer)
      method_name = extract_method_name(source)

      {method_name: method_name, source: source}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs method_name: Symbol?
    # @rbs source: String -- parsed source code
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(method_name:, source:)
      children = [
        Node.new(:name, [method_name]),
        ArgumentsParser.new(source).parse
      ]

      Node.new :macro, children.reject(&:empty?), urtext: urtext, source: source
    end

    private

    def extract_key(tokenizer)
      return nil unless tokenizer.key_tokens.any?
      tokenizer.key_tokens.map(&:value).join
    end

    def extract_source(key, tokenizer)
      return "#{Sigils::FORMAT_METHOD}('#{Sigils::FORMAT_PREFIX}#{key}#{urtext.partition(key).last}')" if key in String

      case tokenizer.method_tokens.first&.value
      in String => method if Fmt.registry.any?(method.to_sym)
        urtext
      in String => method if Sigils::FORMAT_SPECIFIERS.any?(method[-1])
        "#{Sigils::FORMAT_METHOD}('#{Sigils::FORMAT_PREFIX}#{urtext}')"
      else
        "#{Sigils::FORMAT_METHOD}('#{urtext}')"
      end
    end

    def extract_method_name(source)
      tokenizer = Tokenizer.new(source)
      tokenizer.tokenize
      tokenizer.method_tokens.first.value.to_sym
    end
  end
end
