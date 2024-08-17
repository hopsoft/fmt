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
    # @rbs return: MacroNode
    def parse
      cache urtext do
        # 1) build child AST nodes
        callable = Fmt.registry[key]
        procedure = ProcedureParser.new(callable).parse
        procedure = nil if procedure.source.empty?
        arguments = ArgumentsParser.new(args_text).parse
        arguments = nil if arguments.source.empty?

        # 2) assemble the AST children
        children = []
        children << procedure if procedure
        children << arguments if arguments

        # 3) build the parsed source
        source = children.map(&:source).join

        # 4) build the AST
        MacroNode.new(*children, urtext: urtext, source: source)
      end
    end

    private

    def formatter?
      key == Sigils::FORMAT_METHOD
    end

    def args_text
      # TODO: detect key in formatter text
      return "#{Sigils::ARGS_PREFIX}%Q[#{Sigils::FORMAT_PREFIX}#{urtext}]#{Sigils::ARGS_SUFFIX}" if formatter?
      urtext
    end

    # Returns the registry key for the callable in the registry
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
  end
end
