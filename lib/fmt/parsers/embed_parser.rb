# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses embeds from a string and builds an AST (Abstract Syntax Tree)
  class EmbedParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs key: Symbol -- key for embed
    # @rbs placeholder: String -- placeholder for embed
    def initialize(urtext = "", key:, placeholder:)
      @urtext = urtext.to_s
      @key = key
      @placeholder = placeholder
    end

    attr_reader :urtext # : String -- original source code
    attr_reader :key    # : Symbol -- key for embed
    attr_reader :placeholder # : String -- placeholder for embed

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      source = urtext.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)
      {source: source}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(source:)
      key = Node.new(:key, [self.key])
      placeholder = Node.new(:placeholder, [self.placeholder])
      template = TemplateParser.new(source).parse
      children = [key, placeholder, template].reject(&:empty?)
      Node.new(:embed, children, urtext: urtext, source: source)
    end
  end
end
