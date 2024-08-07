# frozen_string_literal: true

# rbs_inline: enabled

require "monitor"
require "singleton"

module Fmt
  # Common Fmt sigils (used in String templates)
  class Sigils
    include MonitorMixin
    include Singleton

    PREFIX = "%" # :: String -- template prefix

    KEY_PREFIXES = ["<", "{"].freeze # :: Array[String] -- named-template prefix

    KEY_SUFFIXES = [">", "}"].freeze # :: Array[String] -- named-template suffix

    ARGS_PREFIX = "(" # :: String -- macro arguments prefix

    ARGS_SUFFIX = ")" # :: String -- macro arguments suffix

    attr_reader :pipe_operator # :: String -- template pipeline operator (i.e. macro delimiter)
    attr_reader :embed_prefix # :: String -- embeded template prefix
    attr_reader :embed_suffix # :: String -- embeded template suffix

    # Changes the pipe operator
    # @rbs value: String -- new pipe operator
    # @rbs return: String -- new pipe operator
    def pipe_operator=(value)
      synchronize { @pipe_operator = value.to_s }
    end

    # Changes the embed prefix
    # @rbs value: String -- new embed prefix
    # @rbs return: String -- new embed prefix
    def embed_prefix=(value)
      synchronize { @embed_prefix = value.to_s }
    end

    # Changes the embed suffix
    # @rbs value: String -- new embed suffix
    # @rbs return: String -- new embed suffix
    def embed_suffix=(value)
      synchronize { @embed_suffix = value.to_s }
    end

    private

    def initialize
      @pipe_operator = "|>"
      @embed_prefix = "{{"
      @embed_suffix = "}}"
    end

    # Expose instance methods on the Fmt::Sigils class
    public_instance_methods(false).each do |name|
      define_singleton_method name, ->(*a, **k, &b) { instance.public_send(name, *a, **k, &b) }
    end
  end
end
