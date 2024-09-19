# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses embeds from a string and builds an AST (Abstract Syntax Tree)
  class EmbedParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs placeholder: String -- placeholder for embed
    def initialize(urtext = "", placeholder:)
      @urtext = urtext.to_s
      @placeholder = placeholder
    end

    attr_reader :urtext # : String -- original source code
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
      {}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(**)
      placeholder = Node.new(:placeholder, [self.placeholder])
      template = TemplateParser.new(template_urtext).parse
      children = [placeholder, template].reject(&:empty?)
      Node.new(:embed, children, urtext: urtext, source: urtext)
    end

    private

    # Returns the template urtext
    # @rbs return: String
    def template_urtext
      urtext.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)
    end
  end
end
