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
      scanner = StringScanner.new(template.source)
      output = scanner.scan_until(PIPELINE_START).to_s

      # execute pipelines
      template.pipelines.each do |pipeline|
        pipeline.macros.each do |macro|
          output = case macro
          in name: Sigils::FORMAT_METHOD then invoke_formatter(output, macro, *args, **kwargs)
          else invoke_macro(output, macro)
          end
        end
      end

      # final result
      template.urtext.sub template.source, output.to_s
    end

    private

    # Invokes native Ruby string formatting
    # @rbs context: Object              -- self in callable (Proc) @note Context will be cast to String
    # @rbs macro: Macro                 -- macro to use (source, arguments, etc.)
    # @rbs args: Array[Object]          -- positional arguments (user provided)
    # @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
    # @rbs return: String
    def invoke_formatter(context, macro, *args, **kwargs)
      callable = Fmt.registry[[Kernel, macro.name]]
      context = "#{context}#{macro.arguments.args[0]}"
      context.instance_exec(*args, **kwargs, &callable)
    rescue => error
      # rubocop:disable Layout/ExtraSpacing
      case [args, kwargs]
      in [*] => args, {}             if args.any?                then raise FormatError, "#{macro.name}(#{context.inspect}, #{args.map(&:inspect).join(", ")}) #{error.inspect}"
      in [], {**} => kwargs          if kwargs.any?              then raise FormatError, "#{macro.name}(#{context.inspect}, #{kwargs.inspect}) #{error.inspect}"
      in [*] => args, {**} => kwargs if args.any? && kwargs.any? then raise FormatError, "#{macro.name}(#{context.inspect}, #{args.map(&:inspect).join(", ")}, #{kwargs.inspect}) #{error.inspect}"
      else                                                            raise FormatError, "#{macro.name}(#{context.inspect}) #{error.inspect}"
      end
      # rubocop:enable Layout/ExtraSpacing
    end

    # Invokes a macro
    # @rbs context: Object -- self in callable (Proc)
    # @rbs macro: Macro    -- macro to use (source, arguments, etc.)
    # @rbs return: Object  -- result
    def invoke_macro(context, macro)
      callable = Fmt.registry[[context.class, macro.name]] || Fmt.registry[[Object, macro.name]]
      raise Error, "[#{context.class.name} | Object, #{macro.name}] is not a registered formatter!" unless callable

      args = macro.arguments.args
      kwargs = macro.arguments.kwargs

      context.instance_exec(*args, **kwargs, &callable)
    rescue => error
      # rubocop:disable Layout/ExtraSpacing
      case [macro.arguments.args, macro.arguments.kwargs]
      in [*] => args, {}             if args.any?                then raise MacroError, "#{context.inspect}.#{macro.name}(#{args.map(&:inspect).join(", ")}) #{error.inspect}"
      in [], {**} => kwargs          if kwargs.any?              then raise MacroError, "#{context.inspect}.#{macro.name}(#{kwargs.inspect}) #{error.inspect}"
      in [*] => args, {**} => kwargs if args.any? && kwargs.any? then raise MacroError, "#{context.inspect}.#{macro.name}(#{args.map(&:inspect).join(", ")}, #{kwargs.inspect}) #{error.inspect}"
      else                                                            raise MacroError, "#{context.inspect}.#{macro.name} #{error.inspect}"
      end
      # rubocop:enable Layout/ExtraSpacing
    end
  end
end
