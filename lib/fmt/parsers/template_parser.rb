# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateParser < Parser
    FORMAT_PREFIX = Regexp.new(Regexp.escape(Sigils::FORMAT_PREFIX)).freeze       # :: Regexp -- template prefix
    KEY_PREFIX = Regexp.new("(?<!\\s|%%)[%s]" % Sigils::KEY_PREFIXES.join).freeze # :: Regexp -- named-template key prefix
    KEY_VALUE = /\w+/                                                             # :: Regexp -- named-template key value
    KEY_SUFFIX = Regexp.new("[%s]" % Sigils::KEY_SUFFIXES.join).freeze            # :: Regexp -- named-template key suffix

    # :: Regexp -- macros
    MACROS = Regexp.new("(?=\\s|%%|%{embed_prefix}|$)(.*[%{args_suffix}])*" % {
      embed_prefix: Regexp.escape(Sigils::EMBED_PREFIX),
      embed_suffix: Regexp.escape(Sigils::EMBED_SUFFIX),
      args_suffix: Sigils::ARGS_SUFFIX
    }).freeze

    # Constructor
    # @rbs scanner: StringScanner -- scanner to use
    def initialize(urtext = "")
      @urtext = urtext.to_s
      @scanner = StringScanner.new(urtext)
    end

    attr_reader :scanner  # :: StringScanner -- scanner to use
    attr_reader :urtext   # :: String -- original source code

    # Parses the urtext (original source code)
    # @rbs return: Node[TemplateNode]
    def parse
      cache urtext do
        # @note the order of operations below is important
        #       as we are using a StringScanner to parse the template

        # parse embedded templates and update the scanner string before continuing
        parse_embeds

        # advance to the start of the template (prefix == "%")
        scanner.scan_until FORMAT_PREFIX
        return unless scanner.matched?

        # extract
        extract_key
        extract_pipeline

        # build
        build_children
        build_source
        TemplateNode.new(*children, urtext: urtext, source: source)
      end
    end

    protected

    attr_reader :key      # :: Node  -- [:key, *]
    attr_reader :pipeline # :: Node  -- [:pipeline, *]
    attr_reader :embeds   # :: Node? -- [:embeds, *]
    attr_reader :children # :: Array[Node] -- [[:key, *], [:pipeline, *], [:embeds, *]]
    attr_reader :source   # :: String

    private

    # Parses embedded (nested) templates and updates the scanner string
    def parse_embeds
      @embeds ||= begin
        source = scanner.rest
        EmbedParser.new(source).parse.tap do |embeds|
          embeds.children.each do |embed|
            placeholder = embed.dig(:placeholder, String)
            scanner.string = scanner.rest.sub(embed.urtext, placeholder)
          end
        end
      end
    end

    # Extracts the key (named placeholder)
    # @rbs return: Symbol?
    def extract_key
      @key ||= begin
        scanner.skip_until KEY_PREFIX
        key = scanner.scan(KEY_VALUE) if scanner.matched?
        scanner.skip_until KEY_SUFFIX if scanner.matched?
        key
      end
    end

    # Extracts the pipeline (macros)
    # @rbs return: String?
    def extract_pipeline
      @pipeline ||= scanner.scan_until(MACROS)
    end

    # Builds child AST nodes
    # @rbs return: Array[Node, PipelineAST, EmbedNode]
    def build_children
      @children ||= [].tap do |children|
        children << Node.new(:key, [key]) if key
        children << PipelineParser.new(pipeline).parse if pipeline
        children << embeds unless embeds.empty?
      end
    end

    # Builds the parsed source code
    # @rbs return: String
    def build_source
      @source ||= begin
        list = [Sigils::FORMAT_PREFIX]
        list << "#{Sigils::KEY_PREFIXES[0]}#{key}#{Sigils::KEY_SUFFIXES[0]}" if key
        list << children.find { _1 in [:pipeline, *] }&.source
        list << scanner.rest
        list.join
      end
    end
  end
end
