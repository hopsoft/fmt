# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Extends behavior of AST::Node
  class Node < AST::Node
    extend Forwardable

    class << self
      # Finds all Node child nodes
      # @rbs node: Node -- node to search
      # @rbs return: Array[Node]
      def node_children(node)
        list = []
        node.children.each do |child|
          list << child if child.is_a?(Node)
        end
        list
      end

      # Recursively finds all Nodes in the tree
      # @rbs node: Node -- node to search
      # @rbs return: Array[Node]
      def node_descendants(node)
        list = []
        node.children.each do |child|
          list << child if child.is_a?(Node)
          list.concat node_children(child)
        end
        list
      end
    end

    # Constructor
    # @rbs type: Symbol
    # @rbs children: Array[Node]
    # @rbs properties: Hash[Symbol, Object]
    def initialize(type, children = [], properties = {urtext: "", source: ""})
      @properties = properties
      define_properties properties
      super
    end

    attr_reader :properties # : Hash[Symbol, Object]

    # Returns the child at the specified index
    # @rbs index: Integer -- index of child node
    # @rbs return: Node? | Object?
    def_delegator :children, :[]

    # Indicates if no children exist
    # @rbs return: bool
    def_delegator :children, :empty?

    # Returns the number of children
    # @rbs return: Integer
    def_delegator :children, :size

    # Recursively searches the tree for a descendant node
    # @rbs types: Array[Object] -- node types to find
    # @rbs return: Node?
    def dig(*types)
      node = find(types.shift) if types.any?
      node = node.find(types.shift) while node && types.any?
      node
    end

    # Finds the first child node of the specified type
    # @rbs type: Object -- node type to find
    # @rbs return: Node?
    def find(type)
      case type
      in Symbol then children.find { _1 in [^type, *] }
      in Class then children.find { _1 in ^type }
      end
    end

    # Flattens Node descendants into a one dimensional array
    # @rbs return: Array[Node]
    def flatten
      node_descendants.prepend self
    end

    # Finds all child nodes of the specified type
    # @rbs type: Object -- node type to select
    # @rbs return: Node?
    def select(type)
      [].concat case type
      in Symbol then children.select { _1 in [^type, *] }
      in Class then children.select { _1 in ^type }
      else []
      end
    end

    # String representation of the node (AST)
    # @rbs squish: bool -- remove extra whitespace
    # @rbs return: String
    def to_s(squish: false)
      value = super()
      return value unless squish
      value.gsub(/\s{2,}/, " ")
    end

    private

    # Finds all Node child nodes
    # @rbs return: Array[Node]
    def node_children
      self.class.node_children self
    end

    # Recursively finds all Node nodes in the tree
    # @rbs return: Array[Node]
    def node_descendants
      self.class.node_descendants self
    end

    # Defines accessor methods for properties on the receiver
    # @rbs properties: Hash[Symbol, Object] -- exposed as instance methods
    def define_properties(properties)
      properties.each do |key, val|
        next if singleton_class.public_instance_methods(false).include?(key)
        singleton_class.define_method(key) { val }
      end
    end
  end
end
