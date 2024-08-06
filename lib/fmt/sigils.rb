# frozen_string_literal: true

# rbs_inline: enabled

require "forwardable"
require "monitor"
require "singleton"

module Fmt
  # Common Fmt sigils (used in String templates)
  class Sigils
    include MonitorMixin
    include Singleton

    class << self
      extend Forwardable

      # The pipe operator
      # @rbs return: String
      def_delegator :instance, :pipe_operator

      # The embed prefix
      # @rbs return: String
      def_delegator :instance, :embed_prefix

      # The embed suffix
      # @rbs return: String
      def_delegator :instance, :embed_suffix

      # Changes the pipe operator
      # @rbs value: String -- new pipe operator
      # @rbs return: String -- new pipe operator
      def pipe_operator=(value)
        synchronize { @pipe_operator = instance.value.to_s }
      end

      # Changes the embed prefix
      # @rbs value: String -- new embed prefix
      # @rbs return: String -- new embed prefix
      def embed_prefix=(value)
        synchronize { @embed_prefix = instance.value.to_s }
      end

      # Changes the embed suffix
      # @rbs value: String -- new embed suffix
      # @rbs return: String -- new embed suffix
      def embed_suffix=(value)
        synchronize { @embed_suffix = instance.value.to_s }
      end
    end

    PREFIX = "%" # :: String

    KEY_PREFIXES = ["<", "{"].freeze # :: Array[String]

    KEY_SUFFIXES = [">", "}"].freeze # :: Array[String]

    ARGS_PREFIX = "(" # :: String

    ARGS_SUFFIX = ")" # :: String

    attr_reader :pipe_operator # :: String
    attr_reader :embed_prefix # :: String
    attr_reader :embed_suffix # :: String

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
  end
end
