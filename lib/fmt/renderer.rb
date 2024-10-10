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

      render_embeds(*args, **kwargs) do |embed, result|
        kwargs[embed.key] = result
      end

      rendered = template.source
      render_pipelines(*args, **kwargs) do |pipeline, result|
        rendered = rendered.sub(pipeline.urtext, result.to_s)
      end
      rendered
    end

    private

    # Renders all template embeds
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs &block: Proc                 -- block executed for each embed (signature: Proc(Embed, String))
    def render_embeds(*args, **kwargs)
      template.embeds.each do |embed|
        yield embed, Renderer.new(embed.template).render(*args, **kwargs)
      end
    end

    # Renders all template pipelines
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs block: Proc                  -- block executed for each pipeline (signature: Proc(Pipeline, String))
    def render_pipelines(*args, **kwargs)
      template.pipelines.each_with_index do |pipeline, index|
        yield pipeline, render_pipeline(pipeline, *args[index..], **kwargs)
      end
    end

    # Renders a single pipeline
    # @rbs pipeline: Pipeline           -- pipeline to render
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String
    def render_pipeline(pipeline, *args, **kwargs)
      result = nil

      pipeline.macros.each do |macro|
        result = invoke_macro(result, macro, *args, **kwargs)
      end

      result
    end

    # Invokes a macro
    # @rbs context: Object              -- self in callable (Proc)
    # @rbs macro: Macro                 -- macro to use (source, arguments, etc.)
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: Object               -- result
    def invoke_macro(context, macro, *args, **kwargs)
      callable = Fmt.registry[[context.class, macro.name]] || Fmt.registry[[Object, macro.name]]

      case callable
      in nil
        if kwargs.key? macro.name
          kwargs[macro.name]
        else
          quietly do
            context.instance_exec { sprintf(macro.urtext, *args, **kwargs) }
          end
        end
      else
        context.instance_exec(*macro.arguments.args, **macro.arguments.kwargs, &callable)
      end
    rescue => error
      args ||= []
      kwargs ||= {}
      raise_format_error(macro, *args, cause: error, **kwargs)
    end

    # Suppresses verbose output for the duration of the block
    # @rbs block: Proc -- block to execute
    # @rbs return: void
    def quietly
      verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = verbose
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
