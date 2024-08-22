# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Registry for storing and retrieving String formatters i.e. Procs
  class Registry
    extend Forwardable

    INSTANCE_VAR = :@fmt_registry_key # :: Symbol -- instance variable set on registered Procs
    private_constant :INSTANCE_VAR

    # Constructor
    def initialize
      @store = LRUCache.new(capacity: -1)
    end

    def_delegator :store, :to_h # :: Hash[Symbol, Proc]
    def_delegator :store, :[]   # :: Proc -- retrieves a Proc from the registry
    def_delegator :store, :key? # :: bool -- indicates if a key exists in the registry

    # Indicates if a method name is registered for at least one Class
    # @rbs method_name: Symbol -- method name to check
    # @rbs return: bool
    def any?(method_name)
      !!method_names[method_name]
    end

    # Adds a keypair to the registry
    # @rbs key: Array[Class | Module, Symbol] -- key to use
    # @rbs overwrite: bool -- overwrite the existing keypair (default: false)
    # @rbs block: Proc -- Proc to add (optional, if proc is provided)
    # @rbs return: Proc
    def add(key, overwrite: false, &block)
      raise Error, "key must be an Array[Class | Module, Symbol]" unless key in [Class | Module, Symbol]

      return store[key] if store.key?(key) && !overwrite

      store.lock do
        store[key] = block
        block.instance_variable_set INSTANCE_VAR, key
      end

      block
    end

    # Deletes a keypair from the registry
    # @rbs key: Array[Class | Module, Symbol] -- key to delete
    # @rbs return: Proc?
    def delete(key)
      store.lock do
        callable = store.delete(key)
        callable&.remove_instance_variable INSTANCE_VAR
      end
    end

    # Fetches a Proc from the registry
    # @rbs key: Array[Class | Module, Symbol] -- key to retrieve
    # @rbs callable: Proc -- Proc to use if the key is not found (optional, if block is provided)
    # @rbs block: Proc -- block to use if the key is not found (optional, if proc is provided)
    # @rbs return: Proc
    def fetch(key, callable: nil, &block)
      callable ||= block
      store[key] || add(key, &callable)
    end

    # Retrieves the registered key for a Proc
    # @rbs callable: Proc -- Proc to retrieve the key for
    # @rbs return: Symbol?
    def key_for(callable)
      callable&.instance_variable_get INSTANCE_VAR
    end

    # Merges another registry into this one
    # @rbs other: Fmt::Registry -- other registry to merge
    # @rbs return: Fmt::Registry
    def merge!(other)
      raise Error, "other must be a registry" unless other in Registry
      other.to_h.each { add(_1, &_2) }
      self
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
    def with_overrides(overrides, &block)
      return yield unless overrides in Hash
      return yield unless overrides&.any?

      overrides.select! { [_1, _2] in [[Class | Module, Symbol], Proc] }
      originals = store.slice(*(store.keys & overrides.keys))

      store.lock do
        overrides.each { add(_1, overwrite: true, &_2) }
        yield
      end
    ensure
      store.lock do
        overrides&.each { delete _1 }
        originals&.each { add(_1, overwrite: true, &_2) }
      end
    end

    protected

    attr_reader :store # :: LRUCache

    # Hash of registered method names
    # @rbs return: Hash[Symbol, TrueClass]
    def method_names
      store.keys.each_with_object({}) { _2[_1.last] = true }
    end
  end
end
