# frozen_string_literal: true

# rbs_inline: enabled

require "ast"

module Fmt
  class Model
    # Constructor
    # @rbs tokens: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens
    # @rbs return: Fmt::Model
    def initialize(*tokens)
      @tokens = tokens
      process
    end

    attr_reader :processor # :: Fmt::Processor -- processor (override in subclass)
    attr_reader :tokens    # :: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens

    # AST representation of the model
    # @rbs return: AST::Node
    def ast
      raise NotImplementedError, "Must be implemented by subclass"
    end

    protected

    # AST::Node built from the Ripper tokens
    # @example [[lineno, column], type, token, state]
    # @rbs type: Symbol -- node type
    # @rbs return: Array[AST::Node]
    def tokens_ast_node(type)
      node = ast_node(type)
      tokens.each do |token|
        (_lineno, _column), type, tok, _state = token
        child = ast_node(type.to_s.delete_prefix("on_").to_sym, tok)
        node = node.append(child) # @note AST::Nodes are immutable, so we reassign
      end
      node
    end

    # Source string built from Ripper tokens
    # @example [[lineno, column], type, token, state]
    # @rbs return: String
    def tokens_source
      tokens.map { |token| token[2] }.join
    end

    # Builds an AST node
    # @rbs type: Symbol -- node type
    # @rbs children: Array[Object] -- node children
    # @rbs properties: Hash[Symbol, Object] -- node properties
    # @rbs return: AST::Node
    def ast_node(type, *children, **properties)
      AST::Node.new type, children, properties
    end

    private

    # Processes the model
    # @rbs return: void
    def process
      processor&.process ast
    end
  end
end
