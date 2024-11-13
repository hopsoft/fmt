# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses a template from a string and builds an AST (Abstract Syntax Tree)
  class TemplateParser < Parser
    EMBED_PEEK = %r{(?=#{esc Sigils::EMBED_PREFIX})}ou # : Regexp -- detects start of an embed prefix (look ahead)
    PIPELINE_PEEK = %r{(?=[#{Sigils::FORMAT_PREFIX}][^#{Sigils::FORMAT_PREFIX}])}ou # : Regexp -- detects start of a pipeline (look ahead)
    PERCENT_LITERAL = %r{[#{Sigils::FORMAT_PREFIX}]{2}}ou # : Regexp -- detects a percent literal
    WHITESPACE = %r{\s}ou # : Regexp -- detects whitespace

    # Constructor
    # @rbs urtext: String -- original source code
    def initialize(urtext = "")
      @urtext = urtext.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "?")
    end

    attr_reader :urtext  # : String -- original source code

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
      source = urtext

      # 1) extract embeds first and update the source
      embeds = extract_embeds(source)
      embeds.each do |embed|
        source = source.sub(embed[:urtext], embed[:placeholder])
      end

      # 2) extract pipelines
      pipelines = extract_pipelines(source)

      {embeds: embeds, pipelines: pipelines, source: source}
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs embeds: Array[Hash] -- extracted embeds
    # @rbs pipelines: Array[String] -- extracted pipelines
    # @rbs source: String -- parsed source code
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(embeds:, pipelines:, source:)
      embeds = embeds.map { EmbedParser.new(_1[:urtext], **_1.slice(:key, :placeholder)).parse }
      embeds = Node.new(:embeds, embeds, urtext: urtext, source: urtext)

      pipelines = pipelines.map { PipelineParser.new(_1).parse }
      pipelines = Node.new(:pipelines, pipelines, urtext: urtext, source: source)

      children = [embeds, pipelines].reject(&:empty?)

      Node.new :template, children, urtext: urtext, source: source
    end

    private

    # Extracts the next embed with the scanner
    # @rbs scanner: StringScanner -- scanner to extract from
    # @rbs return: String? -- extracted embed
    def extract_next_embed(scanner)
      return nil unless scanner.skip_until(EMBED_PEEK)

      head = Sigils::EMBED_PREFIX[0]
      tail = Sigils::EMBED_SUFFIX[0]
      index = scanner.pos
      stack = 0

      until scanner.eos?
        case scanner.getch
        in ^head then stack += 1
        in ^tail then stack -= 1
        in nil then break
        else # noop
        end

        break if stack.zero?
      end

      return nil unless stack.zero?

      scanner.string[index...scanner.pos]
    end

    # Extracts embed metadata from the source
    # @rbs return: Array[Hash] -- extracted embeds
    def extract_embeds(source)
      scanner = StringScanner.new(source)

      # will iterate until extract_next_embed returns nil... when run
      generator = Enumerator.new do |yielder|
        while (embed = extract_next_embed(scanner))
          yielder << embed
        end
      end

      # runs the generator and returns the resulting array
      embeds = generator.to_a

      embeds.map.with_index do |embed, index|
        key = :"embed_#{index}"
        placeholder = "#{Sigils::FORMAT_PREFIX}#{Sigils::KEY_PREFIXES[-1]}#{key}#{Sigils::KEY_SUFFIXES[-1]}"
        {key: key, placeholder: placeholder, urtext: embed}
      end
    end

    # Extracts the next pipeline with the scanner
    # @rbs scanner: StringScanner -- scanner to extract from
    # @rbs return: String? -- extracted pipeline
    def extract_next_pipeline(scanner)
      return nil unless scanner.skip_until(PIPELINE_PEEK)

      index = scanner.pos

      until scanner.eos?
        len = 1
        val = nil
        val = scanner.peek(len += 1) until val&.valid_encoding?
        if val&.match? PERCENT_LITERAL
          scanner.pos += len
          next
        end

        len = 0
        val = nil
        val = scanner.peek(len += 1) until val&.valid_encoding?
        case [index, scanner.pos, val]
        in [i, pos, Sigils::FORMAT_PREFIX] if i == pos then scanner.pos += len
        in [i, pos, Sigils::FORMAT_PREFIX] if i != pos then break
        in [i, pos, WHITESPACE] if arguments_balanced?(scanner.string[i...pos]) then break
        else scanner.pos += len
        end
      end

      scanner.string[index...scanner.pos]
    end

    # Extracts pipelines from the source
    # @rbs source: String -- source code to extract pipelines from
    # @rbs return: Array[String] -- extracted pipelines
    def extract_pipelines(source)
      scanner = StringScanner.new(source)

      generator = Enumerator.new do |yielder|
        while (pipeline = extract_next_pipeline(scanner))
          yielder << pipeline
        end
      end

      generator.to_a
    end

    # Indicates if arguments are balances in the given list of chars
    # @rbs value: String -- value to check
    # @rbs return: bool
    def arguments_balanced?(value)
      return true if value.nil? || value.empty?
      value.count(Sigils::ARGS_PREFIX) == value.count(Sigils::ARGS_SUFFIX)
    end
  end
end
