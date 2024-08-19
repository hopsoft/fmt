# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class MacroParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # : String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- (macro (procedure (name Symbol)) (arguments (tokens (Symbol, String), *)))
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Array[Node?, Node?] -- [procedure, arguments]
    def extract
      {
        procedure: ProcedureParser.new(callable).parse,
        arguments: ArgumentsParser.new(arguments).parse
      }
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs procedure: Node? -- (procedure (name Symbol))
    # @rbs arguments: Node? -- (arguments (tokens (Symbol, String), *))
    # @rbs return: Node -- (macro (procedure (name Symbol)) (arguments (tokens (Symbol, String), *)))
    def transform(procedure:, arguments:)
      children = [procedure, arguments].reject(&:empty?)

      Node.new :macro, children,
        urtext: urtext,
        source: children.map(&:source).join
    end

    # Indicates if the callable is a String formatter
    # @rbs return: bool
    def formatter?
      key == Sigils::FORMAT_METHOD
    end

    # Registry key for the callable
    # @rbs return: Symbol?
    def key
      @key ||= begin
        tokenizer = MacroTokenizer.new(urtext)
        tokens = tokenizer.tokenize
        key = tokens.first.value.to_sym if tokens.one?
        key = Sigils::FORMAT_METHOD unless key && Fmt.registry.key?(key)
        key
      end
    end

    # Callable Proc for the key
    # @rbs return: Proc?
    def callable
      Fmt.registry[key]
    end

    # Arguments string
    # @rbs return: String
    def arguments
      @arguments ||= formatter? ?
        "#{Sigils::ARGS_PREFIX}%Q[#{Sigils::FORMAT_PREFIX}#{urtext}]#{Sigils::ARGS_SUFFIX}" : # TODO: detect key in formatter text
        urtext
    end
  end
end
