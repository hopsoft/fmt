# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a pipeline from a string and builds an AST (Abstract Syntax Tree)
  class PipelineParser < Parser
    PREFIX = %r{#{esc Sigils::FORMAT_PREFIX}}o # : Regexp -- detects the string format prefix (i.e. the start of a pipeline)
    KEY = %r{^[#{Sigils::NAME_PREFIXES.join}]\w+[#{Sigils::NAME_SUFFIXES.join}]}o # : Regexp -- detects the first macro if keyed
    HEAD = %r{(?=#{esc Sigils::PIPE_OPERATOR}|#{esc Sigils::FORMAT_PREFIX}|#{esc Sigils::EMBED_PREFIX}|\z)}o # : Regexp -- detects the start of a pipeline
    TAIL = %r{(?=#{esc Sigils::FORMAT_PREFIX}|#{esc Sigils::EMBED_PREFIX}|\z)}o # : Regexp -- detects the end of a pipeline

    # Constructor
    # @rbs urtext: String -- original source code
    # @rbs scanner: StringScanner?
    def initialize(urtext = "", scanner: nil)
      @urtext = urtext.to_s
      @scanner = scanner || StringScanner.new(@urtext)
    end

    attr_reader :urtext  # : String -- original source code
    attr_reader :scanner # : StringScanner

    # Parses the urtext (original source code)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      cache(urtext) { super }
    end

    protected

    def extract_first_macro(source)
      scanner = StringScanner.new(source)
      head = scanner.scan_until(HEAD)
      _, key, val = head.partition(KEY)

      case [head, key, val]
      # in [String, nil, nil] if Sigils::FORMAT_SPECIFIERS.any?(head[-1]) then head
      in [String, String, String] if Fmt.registry.any?(val.to_sym) then key
      in [String, String, String] if Sigils::FORMAT_SPECIFIERS.any?(val[-1]) then "#{key}#{val}"
      in [String, String, nil] then key
      in [String, nil, nil] then head
      else nil
      end
    end

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      source = extract_source

      first_macro = extract_first_macro(source)
      macros = case first_macro
      in String then source.partition(first_macro).last.split(Sigils::PIPE_OPERATOR).map(&:strip).reject(&:empty?)
      else source.split(Sigils::PIPE_OPERATOR).map(&:strip).reject(&:empty?)
      end
      macros.prepend(first_macro) if first_macro

      {macros: macros, source: source}
    end

    # Extracts the pipeline source code
    # @rbs return: String
    def extract_source
      scanner.skip_until PREFIX
      scanner.scan_until(TAIL).to_s.strip
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs macros: Array[String] -- extracted components
    # @rbs source: String -- extracted source code
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(macros:, source:)
      macros = macros.map { |macro| MacroParser.new(macro).parse }
      Node.new :pipeline, macros.reject(&:empty?), urtext: urtext, source: source
    end
  end
end
