# frozen_string_literal: true

module Fmt
  # Module that helps build regular expressions
  module Pattern
    extend self

    # Regexp escapes args or kwargs
    # @rbs args: Array[String]? -- arguments to escape
    # @rbs kwargs: Hash[Symbol, String]? -- keyword arguments to escape
    # @rbs return: Array[String]? | Hash[Symbol, String]?
    def escape(*args, **kwargs)
      raise ArgumentError, "args and kwargs are mutually exclusive" if args.any? && kwargs.any?

      return Regexp.escape(args.first) if args.one?
      return args.map { |arg| Regexp.escape arg } if args.any?

      kwargs.each_with_object({}) do |(key, val), memo|
        memo[key] = Regexp.escape val
      end
    end

    # Helper method for creating regular expressions
    # @rbs template: String -- regular expression template
    # @rbs args: Array[Object] -- args to interpolate
    # @rbs escape: bool -- indicates if the template should be escaped
    # @rbs return: Regexp
    def build(template, *args, escape: false)
      template = escape(template) if escape
      return Regexp.new(template) unless args.any?
      Regexp.new(template % args)
    end
  end
end
