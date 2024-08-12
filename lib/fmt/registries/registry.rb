# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Registry for storing and retrieving String formatters i.e. Procs
  class Registry
    include MonitorMixin

    PROC_INSTANCE_VAR = :@fmt_registry_key # :: Symbol -- instance variable set on registered Procs
    private_constant :PROC_INSTANCE_VAR

    # Constructor
    # @rbs return: Fmt::Registry
    def initialize
      super
      @store = {}
    end

    # Retrieves a Proc from the registry
    # @rbs key: String | Symbol -- key to retrieve
    # @rbs return: Proc?
    def [](key)
      key = build_key(key)
      synchronize { store[key] }
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
    # @rbs safe: bool -- indicates if the check should be synchronized (default: true)
    def key?(key, safe: true)
      key = build_key(key)
      return store.key?(key) unless safe
      synchronize { store.key? key }
    end

    # Retrieves the registered key for a Proc
    # @rbs block: Proc -- Proc to retrieve the key for
    # @rbs return: Symbol?
    def key_for(block)
      block&.instance_variable_get PROC_INSTANCE_VAR
    end

    # Registry keys
    # @rbs return: Array[Symbol]
    def keys
      synchronize { store.keys }
    end

    # Registry values
    # @rbs return: Array[Proc]
    def values
      synchronize { store.values }
    end

    # Adds a keypair to the registry
    # @rbs key: String | Symbol -- key to use
    # @rbs overwrite: bool -- overwrite the existing keypair (default: false)
    # @rbs proc: Proc -- Proc to add (optional, if block is provided)
    # @rbs block: Proc -- Proc to add (optional, if proc is provided)
    # @rbs return: Proc
    def add(key, overwrite: false, proc: nil, &block)
      key = build_key(key)
      block ||= binding.local_variable_get(:proc)

      return unless block.is_a?(Proc)
      return self[key] if key?(key) && !overwrite

      synchronize do
        block.tap do |b|
          store[key] = b
          b.instance_variable_set PROC_INSTANCE_VAR, key
        end
      end
    end

    # Deletes a keypair from the registry
    # @rbs key: String | Symbol -- key to delete
    # @rbs return: Proc?
    def delete(key)
      key = build_key(key)
      synchronize do
        store.delete(key).tap do |b|
          b&.remove_instance_variable PROC_INSTANCE_VAR
        end
      end
    end

    # Fetches a Proc from the registry
    # @rbs key: String | Symbol -- key to retrieve
    # @rbs safe: bool -- indicates if the fetch should be synchronized (default: true)
    # @rbs proc: Proc -- Proc to use if the key is not found (optional, if block is provided)
    # @rbs block: Proc -- block to use if the key is not found (optional, if proc is provided)
    # @rbs return: Proc
    def fetch(key, safe: true, proc: nil, &block)
      key = build_key(key)
      block ||= binding.local_variable_get(:proc)
      value = safe ? self[key] : store[key]
      value || add(key, proc: block)
    end

    # Merges another registry into this one
    # @rbs other: Fmt::Registry -- other registry to merge
    # @rbs return: Fmt::Registry
    def merge!(other)
      other.to_h.each { |key, val| add key, proc: val }
      self
    end

    # Converts the registry to a Hash
    # @rbs return: Hash[Symbol, Proc]
    def to_h
      synchronize { store.dup }
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

      overrides = overrides.transform_keys { |key| build_key key }
      originals = store.slice(*overrides.keys)
      overrides.each { |key, val| add key, overwrite: true, proc: val }

      yield
    ensure
      synchronize do
        overrides&.each { |key, _| delete key }
        originals&.each { |key, val| add key, overwrite: true, proc: val }
      end
    end

    protected

    attr_reader :store     # :: Hash[Symbol, Proc]
    attr_reader :procstore # :: Hash[String, Symbol] -- supports reverse lookup by Proc

    # Builds a store key
    # @rbs value: String | Symbol -- value to build the key for
    # @rbs return: Symbol
    def build_key(value)
      value.to_sym
    end
  end
end
