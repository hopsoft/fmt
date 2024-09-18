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
        text = case object
        in String then object
        in Symbol then object.to_s
        else object.inspect
        end
        Fmt "%s|>to_s|>#{pipeline.join("|>")}", text
      end

      # Formats an object with Fmt and prints to STDOUT
      # @rbs object [Object] -- object to format (coerced to String)
      # @rbs pipeline [Array[String | Symbol]] -- Fmt pipeline
      # @rbs return void
      def fmt_print(object, *pipeline)
        puts fmt(object, *pipeline)
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
