# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a template from a string and builds an AST (Abstract Syntax Tree)
  class TemplateParser < Parser
    # FORMAT_START = Regexp.new(Sigils::FORMAT_PREFIX).freeze # :: Regexp
    # PIPELINE = Regexp.new("(?=%s|%s|$)" % [Sigils::FORMAT_PREFIX, Regexp.escape(Sigils::EMBED_PREFIX)]).freeze # :: Regexp

    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs scanner: StringScanner?
    def initialize(urtext = "", scanner: nil)
      @urtext = urtext.to_s
      @scanner = scanner || StringScanner.new(@urtext)
    end

    attr_reader :urtext  # :: String -- original source code
    attr_reader :scanner # :: StringScanner?

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(source) { super }
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
      return Node.new(:template, [], scanner: scanner) if source.empty?

      embeds = parse_embeds
      pipelines = parse_pipelines(embeds)

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
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse_embeds
      embeds = []
      scanner = StringScanner.new(source)
      template = EmbedParser.new(source, scanner: scanner).parse

      until template.empty?
        embeds << template
        template = EmbedParser.new(scanner.rest, scanner: scanner).parse
        break unless scanner.matched?
        break if scanner.eos?
      end

      Node.new :embeds, embeds, urtext: urtext, source: source
    ensure
      embeds.each { |embed| embed.properties.delete :scanner }
    end

    # Parses all pipelines contained in the source
    # @rbs embeds: Node -- AST (Abstract Syntax Tree)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse_pipelines(embeds)
      pipelines = []

      scanner = StringScanner.new(pipeline_urtext(embeds))
      pipeline = PipelineParser.new(scanner.rest, scanner: scanner).parse

      until pipeline.empty?
        pipelines << pipeline
        break if scanner.eos?
        pipeline = PipelineParser.new(scanner.rest, scanner: scanner).parse
      end

      Node.new :pipelines, pipelines, urtext: urtext, source: urtext
    ensure
      pipelines.each { |pipeline| pipeline.properties.delete :scanner }
    end

    # Removes embedded templates prior to pipeline parsing
    # @rbs embeds: Node -- AST (Abstract Syntax Tree)
    # @rbs return: String
    def pipeline_urtext(embeds)
      text = source
      embeds.children.each do |embed|
        remove = "%s%s%s" % [Sigils::EMBED_PREFIX, embed.source, Sigils::EMBED_SUFFIX]
        text = text.sub(remove, "")
      end
      text
    end

    # Returns the parsed source code
    # @rbs return: String
    def source
      return urtext unless embed?
      urtext.delete_prefix(Sigils::EMBED_PREFIX).delete_suffix(Sigils::EMBED_SUFFIX)
    end
  end
end
