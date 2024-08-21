# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Represents arguments for a method call
  #
  # Arguments are comprised of:
  # 1. args: Array[Object]
  # 2. kwargs: Hash[Symbol, Object]
  #
  class Arguments < Model
    # Constructor
    # @rbs ast: Node
    def initialize(ast)
      @args = []
      @kwargs = {}
      super
    end

    attr_reader :args   # :: Array[Object] -- positional arguments
    attr_reader :kwargs # :: Hash[Symbol, Object] -- keyword arguments

    # Hash representation of the model (required for pattern matching)
    # @rbs return: Hash[Symbol, Object]
    def to_h
      super.merge(
        args: args,
        kwargs: kwargs
      )
    end

    # ..........................................................................
    # @!group AST Processors
    # ..........................................................................

    # Processes an arguments AST node
    # @rbs node: Node
    # @rbs return: void
    def on_arguments(node)
      process_all node.children
    end

    # Processes a tokens AST node
    # @rbs node: Node
    # @rbs return: void
    def on_tokens(node)
      process_all node.children
    end

    # Processes a keyword AST node
    # @rbs node: Node
    # @rbs return: nil | true | false | Object
    def on_kw(node)
      case node.children.first
      when "nil" then assign(nil)
      when "true" then assign(true)
      when "false" then assign(false)
      end
    end

    # Processes a string AST node
    # @rbs node: Node
    # @rbs return: String
    def on_tstring_content(node)
      assign node.children.first
    end

    # Processes a symbol AST Node
    # @rbs node: Node
    # @rbs return: Symbol
    def on_symbol(node)
      assign node.children.first.to_sym
    end

    # Processes a symbol start AST Node
    # @rbs node: Node
    # @rbs return: void
    def on_symbeg(node)
      @next_ident_is_symbol = true
    end

    # Processes an identifier AST Node
    # @rbs node: Node
    # @rbs return: Symbol?
    def on_ident(node)
      assign node.children.first.to_sym if @next_ident_is_symbol
    ensure
      @next_ident_is_symbol = false
    end

    # Processes an integer AST node
    # @rbs node: Node
    # @rbs return: Integer
    def on_int(node)
      assign node.children.first.to_i
    end

    # Processes a float AST node
    # @rbs node: Node
    # @rbs return: Float
    def on_float(node)
      assign node.children.first.to_f
    end

    # Processes a rational AST node
    # @rbs node: Node
    # @rbs return: Rational
    def on_rational(node)
      assign Rational(node.children.first)
    end

    # Processes an imaginary (complex) AST node
    # @rbs node: Node
    # @rbs return: Complex
    def on_imaginary(node)
      assign Complex(0, node.children.first.to_f)
    end

    # ..........................................................................
    # @!group Composite Data Types (Arrays, Hashes, Sets)
    # ..........................................................................

    # Processes a left bracket AST node
    # @rbs node: Node
    # @rbs return: Array
    def on_lbracket(node)
      assign([])
    end

    # Processes a left brace AST node
    # @rbs node: Node
    # @rbs return: Hash
    def on_lbrace(node)
      assign({})
    end

    # Process a label (hash key) AST node
    # @rbs node: Node
    # @rbs return: void
    def on_label(node)
      label = node.children.first
      label = label.chop.to_sym if label.end_with?(":")
      assign nil, label: label # assign placeholder
    end

    private

    # Assigns a value to the receiver
    # @rbs value: Object -- value to assign
    # @rbs label: Symbol? -- label to use (if applicable)
    # @rbs return: Object
    def assign(value, label: nil)
      receiver(label: label).tap do |rec|
        case rec
        when Array then rec << value
        when Hash then rec[label || rec.keys.last] = value
        end
      end
    end

    # Receiver that the processed value will be assigned to
    # @rbs label: Symbol? -- label to use (if applicable)
    # @rbs return: Array | Hash
    def receiver(label: nil)
      rec = find_receiver(kwargs) if kwargs.any?
      rec ||= find_receiver(args) || args

      case [rec, label]
      in [[*], Symbol] then kwargs # <- 1) Array with label
      else rec # <--------------------- 2) Composite without label
      end
    end

    # Finds the receiver that the processed value will be assigned to
    # @rbs obj: Object
    # @rbs return: Array? | Hash?
    def find_receiver(obj)
      case obj
      in [*, [*] | {**}] then find_receiver(obj.last) # <----------------------- 1) Array with composite last entry
      in { ** } if composite?(obj.values.last) then find_receiver(obj.last) # <- 2) Hash with composite last entry
      in [*] | { ** } then obj # <---------------------------------------------- 3) Composite (empty or last entry is a primitive)
      else nil
      end
    end

    # Indicates if the value is a composite type (Array or Hash)
    # @rbs value: Object -- value to check
    # @rbs return: bool
    def composite?(value)
      value.is_a?(Array) || value.is_a?(Hash)
    end
  end
end
