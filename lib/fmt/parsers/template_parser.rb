# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a template from a string and builds an AST (Abstract Syntax Tree)
  class TemplateParser < Parser
    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs scanner: StringScanner?
    def initialize(urtext = "", scanner: nil)
      @urtext = urtext.to_s
      @scanner = scanner || StringScanner.new(@urtext)
    end

    attr_reader :urtext  # : String -- original source code
    attr_reader :scanner # : StringScanner?

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @note Extraction is delegated to the PipelineParser and EmbedParser in transform
    # @rbs return: Hash
    def extract
      {}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(**)
      return Node.new(:template, [], scanner: scanner) if urtext.empty?

      source = urtext

      # parse embeds first
      # @note modifies source before parsing pipelines
      embeds = parse_embeds
      embeds.each_with_index do |embed, index|
        source = source.sub(embed.source, embed.properties[:key])
      end
      embeds = Node.new(:embeds, embeds, urtext: urtext, source: source)

      # parse pipelines
      pipelines = parse_pipelines(source)
      pipelines = Node.new(:pipelines, pipelines, urtext: urtext, source: source)

      children = []
      children << embeds unless embeds.empty?
      children << pipelines unless pipelines.empty?

      Node.new :template, children, urtext: urtext, source: source
    end

    private

    # Indicates if the urtext is an embed (leading and trailing embed delimiters)
    # @rbs return: bool
    def embed?
      urtext.start_with?(Sigils::EMBED_PREFIX) && urtext.end_with?(Sigils::EMBED_SUFFIX)
    end

    # Parses all embeds contained in the urtext
    # @rbs return: Array[Node] -- Array of embed Nodes
    def parse_embeds
      embeds = []
      scanner = StringScanner.new(urtext)
      template = EmbedParser.new(urtext, scanner: scanner).parse

      until template.empty?
        embeds << template
        template = EmbedParser.new(scanner.rest, scanner: scanner).parse
        break unless scanner.matched?
        break if scanner.eos?
      end

      embeds
    ensure
      embeds.each { |embed| embed.properties.delete :scanner }
    end

    # Parses all pipelines contained in the source
    # @rbs urtext: String -- source code
    # @rbs return: Array[Node] -- Array of pipeline Nodes
    def parse_pipelines(urtext)
      pipelines = []

      scanner = StringScanner.new(urtext)
      pipeline = PipelineParser.new(scanner.rest, scanner: scanner).parse

      until pipeline.empty?
        pipelines << pipeline
        break if scanner.eos?
        pipeline = PipelineParser.new(scanner.rest, scanner: scanner).parse
      end

      pipelines
    ensure
      pipelines.each { |pipeline| pipeline.properties.delete :scanner }
    end
  end
end
