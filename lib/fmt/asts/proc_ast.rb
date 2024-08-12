# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ProcAST < AST::Node
    # @rbs return: AST::Node
    def self.stub
      AST::Node.new :proc
    end

    # Constructor
    # @rbs name: Symbol -- registry key for the Proc
    # @rbs return: Fmt::Model
    def initialize(name)
      @source = name.to_s
      @name = name

      super(:proc, [AST::Node.new(:name, [name])])
    end

    attr_reader :source   # :: String -- source code
    attr_reader :name     # :: Symbol -- method name (key in registry)
  end
end
