# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # A threadsafe fixed-size LRU in-memory cache
  # Grows to capacity then evicts the least used entries
  #
  # @example
  #   cache = Fmt::Cache.new
  #
  #   cache.put :key, "value"
  #   cache.get :key
  #   cache.delete :key
  #   cache.fetch :key, "default"
  #   cache.fetch(:key) { "default" }
  #
  # @example Capacity
  #   Fmt::Cache.capacity = 10_000
  class LRUCache
    include MonitorMixin

    DEFAULT_CAPACITY = 5_000 # :: Integer -- default capacity

    # Constructor
    # @rbs capacity: Integer -- max capacity (negative values are uncapped, default: 5_000)
    # @rbs return: Fmt::Cache
    def initialize(capacity: DEFAULT_CAPACITY)
      super()
      @capacity = capacity
      @store = {}
    end

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

    # Indicates if the cache is capped
    # @rbs return: bool
    def capped?
      synchronize { capacity >= 0 }
    end

    # Clears the cache
    # @rbs return: void
    def clear
      synchronize { store.clear }
    end

    # Deletes the entry for the specified key
    # @rbs key: String | Symbol -- key to delete
    # @rbs return: Object? -- the deleted value
    def delete(key)
      synchronize { store.delete key }
    end

    # Fetches the value for the specified key
    # Writes the default value if the key is not found
    # @rbs key: String | Symbol -- key to fetch
    # @rbs default: Object -- default value to write
    # @rbs block: Proc -- block to call to get the default value
    # @rbs return: Object -- value
    def fetch(key, default = nil, &block)
      return get(key) if key?(key)
      default ||= block&.call
      synchronize { put key, default }
    end

    # Indicates if the cache is full
    # @rbs return: bool
    def full?
      synchronize { capped? && store.size > capacity }
    end

    # Retrieves the value for the specified key
    # @rbs key: String | Symbol -- key to retrieve
    def get(key)
      synchronize do
        reposition(key) if key?(key)
        store[key]
      end
    end

    # Cache keys
    # @rbs return: Array[Symbol]
    def keys
      synchronize { store.keys }
    end

    # Indicates if the cache contains the specified key
    # @rbs key: String | Symbol -- key to check
    # @rbs return: bool
    def key?(key)
      synchronize { store.key? key }
    end

    # Stores the value for the specified key
    # @rbs key: String | Symbol -- key to store
    # @rbs value: Object -- value to store
    # @rbs return: Object -- value
    def put(key, value)
      synchronize do
        delete key if capped? # keep keey fresh if capped
        store[key] = value
        store.shift if full? # resize the cache if necessary
        value
      end
    end

    # Resets the cache capacity to the default
    # @rbs return: Integer -- capacity
    def reset_capacity
      synchronize { @capacity = DEFAULT_CAPACITY }
    end

    # The current size of the cache (number of entries)
    # @rbs return: Integer
    def size
      synchronize { store.size }
    end

    # Returns a Hash with only the given keys
    # @rbs keys: Array[Object] -- keys to include
    # @rbs return: Hash[Object, Object]
    def slice(*keys)
      synchronize { store.slice(*keys) }
    end

    # Hash representation of the cache
    # @rbs return: Hash[Symbol, Proc]
    def to_h
      synchronize { store.dup }
    end

    # Cache values
    # @rbs return: Array[Object]
    def values
      synchronize { store.values }
    end

    # Executes a block with a synchronized mutex
    # @rbs block: Proc -- block to execute
    def lock(&block)
      synchronize(&block)
    end

    alias_method :[], :get  # :: Object -- alias for get
    alias_method :[]=, :put # :: Object -- alias for put

    private

    attr_reader :store # :: Hash[Symbol, Object]

    # Moves the key to the end keeping it fresh
    # @rbs key: Symbol -- key to reposition
    # @rbs return: Object -- value
    def reposition(key)
      value = store.delete(key)
      store[key] = value
    end
  end
end
