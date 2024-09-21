# frozen_string_literal: true

# rbs_inline: enabled
#
require_relative "fmt/boot"

# Extends native Ruby String format specifications
# @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
module Fmt
  LOCK = Monitor.new # : Monitor
  private_constant :LOCK

  # Standard error class for Fmt
  class Error < StandardError; end

  # Error for formatting failures
  class FormatError < Error; end

  class << self
    # Global registry for storing and retrieving String formatters i.e. Procs
    def registry
      @registry ||= LOCK.synchronize do
        NativeRegistry.new.merge! RainbowRegistry.new
      end
    end

    # Adds a keypair to the registry
    # @rbs key: Array[Class | Module, Symbol] -- key to use
    # @rbs overwrite: bool -- overwrite the existing keypair (default: false)
    # @rbs block: Proc -- Proc to add (optional, if proc is provided)
    # @rbs return: Proc
    def register(...)
      registry.add(...)
    end

    # Deletes a keypair from the registry
    # @rbs key: Array[Class | Module, Symbol] -- key to delete
    # @rbs return: Proc?
    def unregister(...)
      registry.delete(...)
    end

    # Executes a block with registry overrides
    #
    # @note Overrides will temporarily be added to the registry
    #       and will overwrite existing entries for the duration of the block
    #       Non overriden entries remain unchanged
    #
    # @rbs overrides: Hash[Array[Class | Module, Symbol], Proc] -- overrides to apply
    # @rbs block: Proc -- block to execute with overrides
    # @rbs return: void
    def with_overrides(...)
      registry.with_overrides(...)
    end
  end
end

# Top level helper for formatting and rendering a source string
# @rbs source: String -- string to format
# @rbs args: Array[Object]          -- positional arguments (user provided)
# @rbs kwargs: Hash[Symbol, Object] -- keyword arguments (user provided)
# @rbs return: String               -- rendered template
def Fmt(source, *args, **kwargs)
  ast = Fmt::TemplateParser.new(source).parse
  template = Fmt::Template.new(ast)
  renderer = Fmt::Renderer.new(template)
  renderer.render(*args, **kwargs)
end
