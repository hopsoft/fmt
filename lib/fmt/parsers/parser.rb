# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Responsible for parsing various inputs and returning an AST (Abstract Syntax Tree)
  #
  # Mechanics are similar to an ETL pipeline (Extract, Transform, Load), however,
  # parsers only handle extracting and transforming.
  #
  # Loading is handled by AST processors (Models)
  # @see lib/fmt/models/
  class Parser
    Cache = Fmt::LRUCache.new # : Fmt::LRUCache -- local in-memory cache

    # Escapes a string for use in a regular expression
    # @rbs value: String -- string to escape
    # @rbs return: String -- escaped string
    def self.esc(value) = Regexp.escape(value.to_s)

    # Parses input passed to the constructor and returns an AST (Abstract Syntax Tree)
    #
    # 1. Extract components
    # 2. Transform to AST
    #
    # @note Subclasses must implement the extract and transform methods
    #
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      extract.then { transform(**_1) }
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      raise Error, "extract must be implemented by subclass"
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs kwargs: Hash[Symbol, Object] -- extracted components
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(**kwargs)
      raise Error, "transform must be implemented by subclass"
    end

    # Cache helper that fetches a value from the cache
    # @rbs key: String -- cache key
    # @rbs block: Proc -- block to execute if the value is not found in the cache
    # @rbs return: Object
    def cache(key, &block)
      Cache.fetch_unsafe("#{self.class.name}/#{key}") { yield }
    end
  end
end
