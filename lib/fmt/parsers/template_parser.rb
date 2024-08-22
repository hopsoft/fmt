# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a template from a string and builds an AST (Abstract Syntax Tree)
  class TemplateParser < Parser
    FORMAT_START = Regexp.new(Sigils::FORMAT_PREFIX).freeze # :: Regexp
    PIPELINE = Regexp.new("(?=%s|%s|$)" % [Sigils::FORMAT_PREFIX, Regexp.escape(Sigils::EMBED_PREFIX)]).freeze # :: Regexp

    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s
      @scanner = StringScanner.new(@urtext)
    end

    attr_reader :urtext # :: String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    attr_reader :scanner # :: StringScanner

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      scanner.scan_until FORMAT_START
      return {pipeline: Node.new(:pipeline)} unless scanner.matched?

      {pipeline: scanner.scan_until(PIPELINE).to_s}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs pipeline: String -- extracted pipeline
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(pipeline:)
      children = []
      children << PipelineParser.new(pipeline).parse
      children << EmbedsParser.new(urtext).parse
      children.reject!(&:empty?)

      source = "%s%s%s" % [Sigils::FORMAT_PREFIX, pipeline, scanner.rest]

      Node.new(:template, children, urtext: urtext, source: source)
    end
  end
end
