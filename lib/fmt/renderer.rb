# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Renders templates to a formatted string
  class Renderer
    PIPELINE_START = Regexp.new("(?=%s)" % [Sigils::FORMAT_PREFIX]).freeze # : Regexp -- detects start of first pipeline

    # Constructor
    # @rbs template: Template
    def initialize(template)
      @template = template
    end

    attr_reader :template # : Template

    # Renders the template to a string
    # @note Positional and Keyword arguments are mutually exclusive
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String               -- rendered template
    def render(*args, **kwargs)
      raise Error, "positional and keyword arguments are mutually exclusive" if args.any? && kwargs.any?

      context = template.source

      render_embeds(context, *args, **kwargs) do |embed, result|
        kwargs[embed.key] = result
      end

      render_pipelines(context, *args, **kwargs)
    end

    private

    # Escapes a string for use in a regular expression
    # @rbs value: String -- string to escape
    # @rbs return: String -- escaped string
    def esc(value) = Regexp.escape(value.to_s)

    # Renders all template embeds
    # @rbs context: String              -- starting context
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs &block: Proc                 -- block to execute after rendering embeds (signature: Proc(String, *args, **kwargs))
    def render_embeds(context, *args, **kwargs)
      template.embeds.each do |embed|
        yield embed, Renderer.new(embed.template).render(*args, **kwargs)
      end
    end

    # Renders all template pipelines
    # @rbs context: String              -- starting context
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String
    def render_pipelines(context, *args, **kwargs)
      template.pipelines.each_with_index do |pipeline, index|
        result = render_pipeline(pipeline, *args[index..], **kwargs)
        context = context.sub(pipeline.urtext, result)
      end

      context
    end

    # Renders a single pipeline
    # @rbs pipeline: Pipeline           -- pipeline to render
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String
    def render_pipeline(pipeline, *args, **kwargs)
      result = ""

      pipeline.macros.each do |macro|
        result = case macro
        in name: Sigils::FORMAT_METHOD
          case [args, kwargs]
          in [], {} then invoke_formatter(macro)
          in [], {**} => kwargs then invoke_formatter(macro, **kwargs)
          in [*], {} then invoke_formatter(macro, *args)
          in [*], {**} => kwargs then invoke_formatter(macro, *args, **kwargs)
          end
        else invoke_macro(result, macro)
        end
      end

      result
    end

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
      raise_format_error(macro, *args, cause: error, **kwargs)
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
      args ||= []
      kwargs ||= {}
      raise_format_error(macro, *args, cause: error, **kwargs)
    end

    # Raises an invocation error if/when Proc invocations fail
    # @rbs macro: Macro                 -- macro that failed
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs cause: Exception             -- exception that caused the error
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: void
    def raise_format_error(macro, *args, cause:, **kwargs)
      raise FormatError, "Error in macro! `#{macro.urtext}` args=#{args.inspect} kwargs=#{kwargs.inspect} cause=#{cause.inspect}"
    end
  end
end
