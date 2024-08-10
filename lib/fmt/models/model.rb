# frozen_string_literal: true

# rbs_inline: enabled

require "ast"
require "forwardable"

module Fmt
  class Model
    extend Forwardable

    # Constructor
    # @rbs tokens: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens
    # @rbs return: Fmt::Model
    def initialize(*tokens)
      @tokens = tokens
      @source = tokens_source
      process
    end

    attr_reader :tokens    # :: Array[[[Integer, Integer], Symbol, String, Object]] -- Ripper tokens
    attr_reader :source    # :: String -- source code based on Ripper tokens

    # AST representation of the model
    # @rbs return: AST::Node
    def ast
      raise NotImplementedError, "Must be implemented by subclass"
    end

    # AST::Node built from the Ripper tokens
    # @rbs return: Array[AST::Node]
    def tokens_ast
      @tokens_ast ||= begin
        node = ast_node(:tokens)
        tokens.each do |token|
          (_lineno, _column), type, tok, _state = token
          child = ast_node(type.to_s.delete_prefix("on_").to_sym, tok)
          node = node.append(child) # @note AST::Nodes are immutable, so we reassign
        end
        node
      end
    end

    protected

    attr_reader :processor # :: Fmt::Processor -- processor (override in subclass)

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
