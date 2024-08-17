# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Parser
    Cache = Fmt::LRUCache.new # :: Fmt::LRUCache

    attr_reader :ast # : Node -- extracted AST

    # Invokes perform and returns an AST
    # @rbs return: Node
    def parse
      raise NotImplementedError, "Must be implemented by subclass"
    end

    protected

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
