# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../cache"

module Fmt
  class Parser
    class << self
      # Regexp escapes args or kwargs
      # @rbs args: Array[String]? -- arguments to escape
      # @rbs kwargs: Hash[Symbol, String]? -- keyword arguments to escape
      # @rbs return: Array[String]? | Hash[Symbol, String]?
      def xcape(*args, **kwargs)
        raise ArgumentError, "args and kwargs are mutually exclusive" if args.any? && kwargs.any?

        return Regexp.escape(args.first) if args.one?
        return args.map { |arg| Regexp.escape arg } if args.any?

        kwargs.each_with_object({}) do |(key, val), memo|
          memo[key] = Regexp.escape val
        end
      end

      # Builds a Regexp with specifier based String formatting
      #
      # @example
      #   x "[%s][b-y][%s]", "a", "z"
      #   x "[%s<prefix>][b-y][%s<suffix>]", prefix: "a", suffix: "z"
      #
      # @rbs template: String -- regular expression template
      # @rbs args: Array[Object] -- args to interpolate
      # @rbs return: Regexp
      def x(template, *args)
        args.none? ? Regexp.new(template) : Regexp.new(template % args)
      end
    end

    attr_reader :value # : Object? -- extracted value

    # Performs the following:
    # 1) Prepares input for tokenization
    # 2) Passes prepared input to a tokenizer for tokenization
    # 3) Returns the tokenized AST
    # @note Subclasses must implement the perform method to support parsing
    # @rbs return: AST::Node
    def parse
      perform
      value
    end

    protected

    # Creates an AST node
    # @rbs type: Symbol -- node type
    # @rbs children: Array[Object]
    # @rbs properties: Hash[Symbol, Object]
    # @rbs return: AST::Node
    def ast(type, *children, **properties)
      AST::Node.new type, children, properties
    end

    # Peforms parsing
    # @note The @value instance variable must be assigned by this method
    # @rbs return: String?
    def perform
      raise NotImplementedError, "Must be implemented by subclass"
    end
  end
end
