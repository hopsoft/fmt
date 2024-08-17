# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgumentsParser < Parser
    ## TODO: move all logic to the tokenizer and remove use of StringScanner in this class
    ##       update the tokenizer to work for string formatting specifiers and (...)
    # PREFIX = /(?=\()/
    # SUFFIX = /\)/

    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
    end

    attr_reader :urtext # : String -- original source code

    protected

    # Parses the urtext (original source code)
    # @rbs return: ArgumentsNode
    def perform
      cache urtext do
        # 1) extract the arguments
        # scanner = StringScanner.new(urtext)
        # scanner.skip_until PREFIX
        # parsed = scanner.scan_until(SUFFIX) if scanner.matched?

        # 2) tokenize the arguments
        tokenizer = ArgumentsTokenizer.new(urtext)
        tokens = tokenizer.tokenize

        # 3) build the AST children
        tokens = tokens.map do |token|
          TokenNode.new(token.type, token.value, urtext: urtext, source: token.value)
        end

        # 4) assemble the AST children
        children = []
        children << Node.new(:tokens, tokens) if tokens.any?

        # 5) build the parsed source
        source = tokens.map(&:source).join

        # 6) build the AST
        ArgumentsNode.new(*children, urtext: urtext, source: source)
      end
    end
  end
end
