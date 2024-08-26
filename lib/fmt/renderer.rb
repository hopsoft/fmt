# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Renderer
    PIPELINE_START = Regexp.new("(?=%s)" % [Sigils::FORMAT_PREFIX]).freeze # :: Regexp -- detects start of first pipeline

    # Constructor
    # @rbs template: Template
    def initialize(template)
      @template = template
    end

    attr_reader :template # :: Template

    # Renders the template to a string
    # @note Positional and Keyword arguments are mutually exclusive
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String               -- rendered template
    def render(*args, **kwargs)
      raise Error, "positional and keyword arguments are mutually exclusive" if args.any? && kwargs.any?

      # start with an empty string
      output = template.source.dup

      pipeline_results = Array.new(template.pipelines.size, "")

      # execute pipelines
      template.pipelines.each_with_index do |pipeline, index|
        pipeline.macros.each do |macro|
          result = case macro
          in name: Sigils::FORMAT_METHOD
            case [args, kwargs]
            in [], {} then invoke_formatter(macro)
            in [], {**} => kwargs then invoke_formatter(macro, **kwargs)
            in [*], {} then invoke_formatter(macro, *args[index, 1])
            in [*], {**} => kwargs then invoke_formatter(macro, *args[index, 1], **kwargs)
            end
          else invoke_macro(pipeline_results[index], macro)
          end
          pipeline_results[index] = result
        end

        output = output.sub(pipeline.source, pipeline_results[index])
      end

      output
    end

    private

    # Invokes native Ruby string formatting
    # @rbs macro: Macro                 -- macro to use (source, arguments, etc.)
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String
    def invoke_formatter(macro, *args, **kwargs)
      callable = Fmt.registry[[Kernel, macro.name]]
      context = macro.arguments.args[0]
      context.instance_exec(*args, **kwargs, &callable)
    rescue => error
      raise_invocation_error(error, context, *args, **kwargs)
    end

    # Invokes a macro
    # @rbs context: Object              -- self in callable (Proc)
    # @rbs macro: Macro                 -- macro to use (source, arguments, etc.)
    # @rbs return: Object               -- result
    def invoke_macro(context, macro)
      callable = Fmt.registry[[context.class, macro.name]] || Fmt.registry[[Object, macro.name]]
      raise Error, "[#{context.class.name} | Object, #{macro.name}] is not a registered formatter!" unless callable

      args = macro.arguments.args
      kwargs = macro.arguments.kwargs

      context.instance_exec(*args, **kwargs, &callable)
    rescue => error
      raise_invocation_error(error, context, *args, **kwargs)
    end

    # Raises an invocation error if/when Proc invocations fail
    # @rbs cause: Exception             -- exception that caused the error
    # @rbs context: Object              -- self in callable (Proc)
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: void
    def raise_invocation_error(cause, context, *args, **kwargs)
      example = case [args.size, kwargs.size]
      in [0, 0] then "sprintf(#{context.inspect})"
      in [*, 0] then "sprintf(#{context.inspect}, #{args.map(&:inspect).join(", ")})"
      in [0, *] then "sprintf(#{context.inspect}, #{kwargs.inspect})"
      end
      raise FormatError, "Did you pass the correct arguments? #{example} -- Cause: #{cause.message}"
    end
  end
end
