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
    def initialize(scanner)
      @scanner = scanner
      @urtext = scanner.rest.dup
    end

    attr_reader :scanner  # :: StringScanner -- scanner to use
    attr_reader :urtext   # :: String -- original source code

    protected

    attr_reader :key      # :: Node  -- [:key, *]
    attr_reader :pipeline # :: Node  -- [:pipeline, *]
    attr_reader :embeds   # :: Node? -- [:embeds, *]
    attr_reader :children # :: Array[Node] -- [[:key, *], [:pipeline, *], [:embeds, *]]
    attr_reader :source   # :: String

    # Parses the urtext (original source code)
    # @rbs return: Node[TemplateNode]
    def perform
      cache urtext do
        # advance to the start of the template (prefix == "%")
        scanner.skip_until FORMAT_PREFIX
        return unless scanner.matched?

        # @note the order of operations below is important
        #       as we are using a StringScanner to parse the template

        # parse embedded templates and update the scanner string before continuing
        parse_embeds

        # extract
        extract_key
        extract_pipeline

        # build
        build_children
        # binding.pry if $nate
        build_source
        # source = "#{Sigils::FORMAT_PREFIX}#{scanner.string}"
        TemplateNode.new(*children, urtext: urtext, source: source)
      end
    end

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
        sources = children.map do |component|
          case component
          in :key, * then "#{Sigils::KEY_PREFIXES[0]}#{key}#{Sigils::KEY_SUFFIXES[0]}"
          in :pipeline, * then component&.source
          in :embeds, * then component.children.map { |embed| embed.dig(:placeholder, String) }.join # todo: preserve whitespace
          else nil
          end
        end

        "#{Sigils::FORMAT_PREFIX}#{sources.compact.join}"
      end
    end
  end
end
