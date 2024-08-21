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
    Cache = Fmt::LRUCache.new # :: Fmt::LRUCache -- local in-memory cache

    attr_reader :ast # : Node -- extracted AST

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

    # Builds a cache key specific to the parser
    # @rbs args: Array[Object] -- args to use in the cache key
    # @rbs return: String
    def cache_key(*args)
      args.prepend(self.class.name).join ":"
    end

    # Cache helper that fetches a value from the cache
    # @rbs args: Array[Object] -- args to use in the cache key
    # @rbs block: Proc -- block to execute if the value is not found in the cache
    # @rbs return: Object
    def cache(*args, &block)
      Cache.fetch(cache_key(*args)) { yield }
    end
  end
end
