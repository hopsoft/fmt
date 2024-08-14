# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class RootParser < Parser
    TEMPLATE_PREFIX = Regexp.new("(?<=%s)" % Regexp.escape(Sigils::TEMPLATE_PREFIX)).freeze # :: Regexp -- template prefix

    # Constructor
    # @rbs source: String -- source code
    # @rbs return: Fmt::ArgsParser
    def initialize(source = "")
      @source = source.to_s
    end

    attr_reader :source # : String -- source code

    protected

    # Parses the source
    # @rbs return: Fmt::RootAST
    def perform
      @ast ||= cache(source) do
        asts = []

        scanner = StringScanner.new(source)
        ast = TemplateParser.new(scanner).parse

        while ast
          asts << ast
          ast = TemplateParser.new(scanner).parse
        end

        RootAST.new(source, *asts)
      end
    end
  end
end
