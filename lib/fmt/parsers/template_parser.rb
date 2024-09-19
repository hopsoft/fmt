# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a template from a string and builds an AST (Abstract Syntax Tree)
  class TemplateParser < Parser
    PIPELINE_HEAD = %r{(?=(?!#{esc Sigils::PIPE_OPERATOR})#{Sigils::FORMAT_PREFIX})}o   # : Regexp -- detects a native Ruby format string
    PIPELINE_TAIL = %r{(?=(\s+#{Sigils::FORMAT_PREFIX})|\z)}o # : Regexp -- detects a pipeline suffix

    EMBED_HEAD = %r{(?=#{esc Sigils::EMBED_PREFIX})}o # : Regexp -- detects an embed prefix
    EMBED_TAIL = %r{#{esc Sigils::EMBED_SUFFIX}}o     # : Regexp -- detects an embed suffix

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
      embeds = extract_embeds

      source = urtext
      embeds.each { source = "#{source[0..._1[:index]]}#{_1[:placeholder]}#{source[(_1[:rindex] + 1)..]}" }

      pipelines = extract_pipelines(source)

      {embeds: embeds, pipelines: pipelines, source: source}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs embeds: Array[Hash] -- extracted embeds
    # @rbs pipelines: Array[String] -- extracted pipelines
    # @rbs source: String -- parsed source code
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(embeds:, pipelines:, source:)
      embeds = embeds.map { EmbedParser.new(_1[:urtext], placeholder: _1[:placeholder]).parse }
      embeds = Node.new(:embeds, embeds, urtext: urtext, source: urtext)

      pipelines = pipelines.map { PipelineParser.new(_1).parse }
      pipelines = Node.new(:pipelines, pipelines, urtext: urtext, source: source)

      children = [embeds, pipelines].reject(&:empty?)

      Node.new :template, children, urtext: urtext, source: source
    end

    private

    def extract_embeds
      embeds = []

      index = nil
      embed = ""

      scanner = StringScanner.new(urtext)
      scanner.skip_until(EMBED_HEAD)

      while scanner.matched?
        index ||= scanner.charpos
        embed = "#{embed}#{scanner.scan_until(EMBED_TAIL)}"

        if embed.scan(EMBED_HEAD).size == embed.scan(EMBED_TAIL).size
          rindex = scanner.charpos
          key = "embed_#{index}_#{rindex}"

          embeds << {
            index: index,
            rindex: rindex,
            placeholder: "#{Sigils::FORMAT_PREFIX}#{Sigils::KEY_PREFIXES[-1]}#{key}#{Sigils::KEY_SUFFIXES[-1]}",
            urtext: embed
          }

          index = nil
          embed = scanner.skip_until(EMBED_HEAD)
        end
      end

      embeds
    end

    def extract_pipelines(source)
      pipelines = []
      pipeline = ""

      scanner = StringScanner.new(source)
      scanner.skip_until(PIPELINE_HEAD)

      while scanner.matched?
        pipeline = scanner.scan_until(PIPELINE_TAIL)

        if scanner.matched?
          pipelines << pipeline
          scanner.skip_until(PIPELINE_HEAD)
        end
      end

      pipelines
    end
  end
end
