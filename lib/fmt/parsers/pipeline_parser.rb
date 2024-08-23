# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a pipeline from a string and builds an AST (Abstract Syntax Tree)
  class PipelineParser < Parser
    # @rbs return: Regexp -- detects the start of a pipeline
    START = Regexp.new(Sigils::FORMAT_PREFIX).freeze

    # @rbs return: Regexp -- detects the possible end of a pipeline
    PIPELINE_FINISH = Regexp.new("(?=\\s|%s|$)" % [Sigils::FORMAT_PREFIX]).freeze

    # @rbs return: Regexp -- detects the end of arguments
    ARGUMENTS_FINISH = Regexp.new("[^%s]+[%s]" % [Sigils::FORMAT_PREFIX, Sigils::ARGS_SUFFIX]).freeze

    # @rbs return: Regexp -- detects a named leading macro
    NAMED_LEAD_MACRO = Regexp.new("^[%s]\\w+[%s]" % [Sigils::NAME_PREFIXES.join, Sigils::NAME_SUFFIXES.join]).freeze

    # @rbs return: Regexp -- detects the end of a macro
    MACRO_FINISH = Regexp.new("(?=%s|$)" % Regexp.escape(Sigils::PIPE_OPERATOR)).freeze

    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs scanner: StringScanner?
    def initialize(urtext = "", scanner: nil)
      @urtext = urtext.to_s
      @scanner = scanner || StringScanner.new(@urtext)
    end

    attr_reader :urtext  # :: String -- original source code
    attr_reader :scanner # :: StringScanner

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      scanner.skip_until(START)

      pipeline = scanner.scan_until(PIPELINE_FINISH) if scanner.matched?
      while scanner.matched? && scanner.match?(ARGUMENTS_FINISH)
        pipeline = "#{pipeline}#{scanner.scan_until(ARGUMENTS_FINISH)}"
        pipeline = "#{pipeline}#{scanner.scan_until(PIPELINE_FINISH)}"
      end

      pipeline = pipeline.to_s.strip
      macros = extract_macros(pipeline)
      pipeline = "#{Sigils::FORMAT_PREFIX}#{pipeline}" unless pipeline.empty?

      {pipeline: pipeline, macros: macros}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs pipeline: String -- extracted pipeline
    # @rbs macros: Array[String] -- extracted components
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(pipeline:, macros:)
      macros = macros.map { |macro| MacroParser.new(macro).parse }
      Node.new :pipeline, macros, urtext: urtext, source: pipeline, scanner: scanner
    end

    private

    # Extracts a named leading macro (includes trailing format content)
    # @rbs pipeline: String -- pipeline to extract from
    # @rbs return: String?
    def extract_named_lead_macro(pipeline)
      scanner = StringScanner.new(pipeline)
      named = scanner.scan_until(NAMED_LEAD_MACRO).to_s.strip
      content = scanner.scan_until(MACRO_FINISH).to_s.strip unless named.empty?

      case [named, content]
      in ["", "" | nil] then nil
      in [*, "" | nil] then named
      in [_, *] if Fmt.registry.any?(content.to_sym) then named
      else "#{named}#{content}"
      end
    end

    # Extracts all macros from the pipeline
    # @rbs pipeline: String -- pipeline to extract from
    # @rbs return: Array[String]
    def extract_macros(pipeline)
      macros = []

      named_lead_macro = extract_named_lead_macro(pipeline)
      if named_lead_macro
        macros << named_lead_macro
        pipeline = pipeline.sub(named_lead_macro, "")
      end

      macros.concat(pipeline.split(Sigils::PIPE_OPERATOR)).map(&:strip).reject(&:empty?)
    end
  end
end
