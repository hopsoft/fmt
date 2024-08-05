# frozen_string_literal: true

# rbs_inline: enabled

require "monitor"
require "singleton"

module Fmt
  # A simple LRU cache with a fixed size
  class Cache
    include MonitorMixin
    include Singleton

    # The cache max capacity (number of entries)
    # @rbs return: Integer
    def capacity
      synchronize { @capacity }
    end

    # Set the max capacity (number of entries)
    # @rbs capacity: Integer -- new max capacity
    # @rbs return: Integer -- new max capacity
    def capacity=(capacity)
      synchronize { @capacity = capacity.to_i }
    end

    # Clears the cache
    # @rbs return: void
    def clear
      synchronize { hash.clear }
    end

    # Deletes the entry for the specified key
    # @rbs key: String | Symbol -- key to delete
    # @rbs return: Object? -- the deleted value
    def delete(key)
      synchronize { hash.delete key }
    end

    # Fetches the value for the specified key
    # Writes the default value if the key is not found
    # @rbs key: String | Symbol -- key to fetch
    # @rbs default: Object -- default value to write
    # @rbs block: Proc -- block to call to get the default value
    # @rbs return: Object -- value
    def fetch(key, default = nil, &block)
      synchronize do
        return get(key) if key?(key)
        value = default || block&.call
        put key, value
      end
    end

    # Retrieves the value for the specified key
    # @rbs key: String | Symbol -- key to retrieve
    def get(key)
      synchronize do
        reposition(key) if key?(key)
        hash[key]
      end
    end

    # Indicates if the cache contains the specified key
    # @rbs key: String | Symbol -- key to check
    # @rbs return: bool
    def key?(key)
      synchronize { hash.key? key }
    end

    # Stores the value for the specified key
    # @rbs key: String | Symbol -- key to store
    # @rbs value: Object -- value to store
    # @rbs return: Object -- value
    def put(key, value)
      synchronize do
        # reposition the key/value pair
        delete key
        hash[key] = value

        # resize the cache if necessary
        hash.shift if size > capacity

        value
      end
    end

    # The current size of the cache (number of entries)
    # @rbs return: Integer
    def size
      synchronize { hash.size }
    end

    private

    # Constructor
    # @rbs return: Fmt::Cache
    def initialize
      super
      @capacity = 5_000
      @hash = {}
    end

    attr_reader :hash # :: Hash[Symbol, Object]

    # Update position (LRU)
    # @rbs key: Symbol -- key to reposition
    # @rbs return: Object -- value
    def reposition(key)
      value = hash.delete(key)
      hash[key] = value
    end
  end
end
