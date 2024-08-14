# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class TemplateAST < AST::Node
    TYPE = :template

    # Constructor
    # @rbs pipeline_ast: Fmt::PipelineAST
    # @rbs specifier: String? -- native Ruby format specifier (@see Sigils::FORMAT_SPECIFIERS)
    # @rbs key: Symbol? -- template key (i.e. "%{key}")
    # @rbs embed_asts: Array[Fmt::EmbedAST]
    # @rbs return: Fmt::TemplateAST
    def initialize(specifier = nil, key = nil, pipeline_ast = nil, *embed_asts)
      @specifier = specifier
      @key = key
      @pipeline_ast = pipeline_ast
      @embed_asts = embed_asts

      # rubocop:disable Layout/ExtraSpacing
      children ||= components.each_with_object([]) do |entry, memo|
        case entry
        in String              then memo << AST::Node.new(:specifier, [entry])
        in Symbol              then memo << AST::Node.new(:key, [entry])
        in Fmt::PipelineAST    then memo << entry
        in Array if entry.any? then memo << entry
        end
      end
      # rubocop:enable Layout/ExtraSpacing

      super(TYPE, children)
    end

    attr_reader :specifier    # :: String? -- native Ruby format specifier
    attr_reader :key          # :: Symbol? -- template key
    attr_reader :pipeline_ast # :: Fmt::PipelineAST?
    attr_reader :embed_asts   # :: Array[Fmt::EmbedAST]

    # AST components
    # @rbs return: Array[String | Symbol | Fmt::PipelineAST | Array[Fmt::EmbedAST]]
    def components
      @components ||= [specifier, key, pipeline_ast, embed_asts].reject do |component|
        # rubocop:disable Layout/ExtraSpacing
        case component
        when nil         then true
        when String      then component.empty?
        when PipelineAST then component.source.empty?
        when Array       then component.empty? || component.all? { |c| c.source.empty? }
        end
        # rubocop:enable Layout/ExtraSpacing
      end
    end

    # Source code
    # @rbs return: String
    def source
      @source ||= begin
        list = components.map do |component|
          # rubocop:disable Layout/ExtraSpacing
          case component
          when String           then component
          when Symbol           then "#{Sigils::KEY_PREFIXES[0]}#{component}#{Sigils::KEY_SUFFIXES[0]}"
          when Fmt::PipelineAST then component.source
          when [Fmt::EmbedAST]  then component.map(&:source).join
          end
          # rubocop:enable Layout/ExtraSpacing
        end
        "#{Sigils::TEMPLATE_PREFIX}#{list.join}"
      end
    end
  end
end
