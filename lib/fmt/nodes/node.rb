# frozen_string_literal: true

# rbs_inline: enabled
# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing

module Fmt
  # Superclass for custom AST nodes
  class Node < AST::Node
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
    def initialize(type, children = [], properties = {})
      define_properties properties
      super
    end

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

    # Finds the first child node of the specified type
    # @rbs type: Symbol -- type to search for
    # @rbs return: Node?
    def find(type)
      case type
      when Symbol then children.find {  _1 in [^type, *]  }
      when Class then children.find { _1 in type }
      end
    end

    # Finds all child nodes of the specified type
    # @rbs type: Symbol -- type to search for
    # @rbs return: Node?
    def select(type)
      [].concat case type
      when Symbol then children.select {  _1 in [^type, *]  }
      when Class then children.select { _1 in type }
      else []
      end
    end

    # Recursively searches the tree for a descendant node
    # @rbs types: Array[Symbol] -- types to search for
    # @rbs return: Node?
    def dig(*types)
      node = find(types.shift) if types.any?
      node = node.find(types.shift) while node && types.any?
      node
    end

    # Indicates if the node does not have any children
    # @rbs return: bool
    def empty?
      children.empty?
    end

    # Flattens AST nodes that have children of the same type
    # @rbs return: Array[Node]
    def flatten
      node_descendants.prepend self
    end

    private

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
