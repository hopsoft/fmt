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

    # Retrieves a Proc from the registry
    # @rbs key: String | Symbol -- key to retrieve
    # @rbs return: Proc?
    def [](key)
      store[key.to_sym]
    end

    # Retrieves an Array of supported method names for the given classes
    # @rbs klasses: Array[Class]
    # @rbs return: Array[Symbol]
    def supported_method_names(*klasses)
      method_names = klasses.each_with_object(Set.new) do |klass, set|
        klass.public_instance_methods.each do |name|
          next if name.to_s.start_with?("_") || name.to_s.end_with?("!")
          set << name
        end
      end
      method_names.to_a.sort
    end

    # Indicates if a key exists in the registry
    # @rbs key: String | Symbol -- key to check
    def key?(key)
      store.key? key.to_sym
    end

    # Retrieves the registered key for a Proc
    # @rbs callable: Proc -- Proc to retrieve the key for
    # @rbs return: Symbol?
    def key_for(callable)
      callable&.instance_variable_get INSTANCE_VAR
    end

    # Adds a keypair to the registry
    # @rbs key: String | Symbol -- key to use
    # @rbs overwrite: bool -- overwrite the existing keypair (default: false)
    # @rbs block: Proc -- Proc to add (optional, if proc is provided)
    # @rbs return: Proc
    def add(key, overwrite: false, &block)
      key = key.to_sym

      return store[key] if store.key?(key) && !overwrite

      store.lock do
        store[key] = block
        block.instance_variable_set INSTANCE_VAR, key
      end

      block
    end

    # Deletes a keypair from the registry
    # @rbs key: String | Symbol -- key to delete
    # @rbs return: Proc?
    def delete(key)
      store.lock do
        callable = store.delete(key.to_sym)
        callable&.remove_instance_variable INSTANCE_VAR
      end
    end

    # Fetches a Proc from the registry
    # @rbs key: String | Symbol -- key to retrieve
    # @rbs callable: Proc -- Proc to use if the key is not found (optional, if block is provided)
    # @rbs block: Proc -- block to use if the key is not found (optional, if proc is provided)
    # @rbs return: Proc
    def fetch(key, callable: nil, &block)
      callable ||= block
      raise Error, "callable must be a proc" unless callable in Proc
      store[key.to_sym] || add(key, &callable)
    end

    # Merges another registry into this one
    # @rbs other: Fmt::Registry -- other registry to merge
    # @rbs return: Fmt::Registry
    def merge!(other)
      raise Error, "other must be a registry" unless other in Registry
      other.to_h.each { |key, block| add(key, &block) }
      self
    end

    # Executes a block with registry overrides
    #
    # @note Overrides will temporarily be added to the registry
    #       and will overwrite existing entries for the duration of the block
    #       Non overriden entries remain unchanged
    #
    # @rbs overrides: Hash[String | Symbol, Proc] -- overrides to apply
    # @rbs block: Proc -- block to execute with overrides
    # @rbs return: void
    def with_overrides(overrides, &block)
      return yield if overrides.nil? || overrides.empty?

      overrides = overrides.transform_keys(&:to_sym)
      originals = store.slice(*(store.keys & overrides.keys))

      store.lock do
        overrides.each do |key, callable|
          raise Error, "override values must be procs" unless callable in Proc
          add(key, overwrite: true, &callable)
        end
        yield
      end
    ensure
      store.lock do
        overrides&.each { |key, _| delete key }
        originals&.each { |key, callable| add(key, overwrite: true, &callable) }
      end
    end

    protected

    attr_reader :store # :: LRUCache
  end
end
