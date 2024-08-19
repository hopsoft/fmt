# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Parses various inputs and returns an AST (Abstract Syntax Tree) that represents the input.
  #
  # The mechanics are similar to an ETL pipeline (Extract, Transform, Load), however,
  # the parser is only responsible for extracting and transforming input.
  #
  # Loading is handled by AST processors. @see lib/fmt/models/
  class Parser
    Cache = Fmt::LRUCache.new # :: Fmt::LRUCache

    attr_reader :ast # : Node -- extracted AST

    # Invokes perform and returns an AST (Abstract Syntax Tree)
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def parse
      extract.then do |components|
        transform(**components)
      end
    end

    protected

    # Extracts components for building the AST (Abstract Syntax Tree)
    # @rbs return: Hash[Symbol, Object] -- extracted components
    def extract
      raise NotImplementedError, "Must be implemented by subclass"
    end

    # Transforms extracted components into an AST (Abstract Syntax Tree)
    # @rbs kwargs: Hash[Symbol, Object] -- extracted components
    # @rbs return: Node -- AST (Abstract Syntax Tree)
    def transform(**kwargs)
      raise NotImplementedError, "Must be implemented by subclass"
    end

    # Generates a cache key specific to the parser
    # @rbs args: Array[Object] -- args to use in the cache key
    # @rbs return: String
    def cache_key(*args)
      args.prepend(self.class.name).join(":")
    end

    # Cache helper that fetchs a value from the cache
    # @rbs args: Array[Object] -- args to use in the cache key
    # @rbs block: Proc -- block to execute if the value is not found in the cache
    # @rbs return: Object
    def cache(*args, &block)
      Cache.fetch(cache_key(*args)) { yield }
    end
  end
end
