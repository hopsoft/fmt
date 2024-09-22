# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  module KernelRefinement
    refine Kernel do
      # Formats an object with Fmt
      # @rbs object [Object] -- object to format (coerced to String)
      # @rbs pipeline [Array[String | Symbol]] -- Fmt pipeline
      # @rbs return [String] -- formatted text
      def fmt(object, *pipeline)
        Fmt pipeline.prepend("%s").join(Sigils::PIPE_OPERATOR), object
      end

      # Formats an object with Fmt and prints to STDOUT
      # @rbs object [Object] -- object to format (coerced to String)
      # @rbs pipeline [Array[String | Symbol]] -- Fmt pipeline
      # @rbs return void
      def fmt_print(object, *pipeline)
        print fmt(object, *pipeline)
      end

      # Formats an object with Fmt and puts to STDOUT
      # @rbs object [Object] -- object to format (coerced to String)
      # @rbs pipeline [Array[String | Symbol]] -- Fmt pipeline
      # @rbs return void
      def fmt_puts(object, *pipeline)
        puts fmt(object, *pipeline)
      end
    end
  end
end
