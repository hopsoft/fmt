# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class ArgsProcessor < Processor
    def initialize
      @args = []
      @kwargs = {}
    end

    attr_reader :args # :: Array[Object] -- positional arguments
    attr_reader :kwargs # :: Hash[Symbol, Object] -- keyword arguments

    # ..........................................................................
    # @!group Top Level Nodes
    # ..........................................................................

    # Processes the args node
    # @rbs node: AST::Node -- node to process
    # @rbs return: void
    def on_args(node)
      process_all node.children
    end

    # Processes the tokens node
    # @rbs node: AST::Node -- node to process
    # @rbs return: void
    def on_tokens(node)
      process_all node.children
    end

    # ..........................................................................
    # @!group Primitive Data Types
    # ..........................................................................

    # Processes a keyword node
    # @rbs node: AST::Node -- node to process
    # @rbs return: nil | true | false | Object
    def on_kw(node)
      case node.children.first
      when "nil" then assign(nil)
      when "true" then assign(true)
      when "false" then assign(false)
      end
    end

    # Processes a String node
    # @rbs node: AST::Node -- node to process
    # @rbs return: String
    def on_tstring_content(node)
      assign node.children.first
    end

    # Processes a Symbol node
    # @rbs node: AST::Node -- node to process
    # @rbs return: Symbol
    def on_symbol(node)
      assign node.children.first.to_sym
    end

    # Processes an Integer node
    # @rbs node: AST::Node -- node to process
    # @rbs return: Integer
    def on_int(node)
      assign node.children.first.to_i
    end

    # Processes a Float node
    # @rbs node: AST::Node -- node to process
    # @rbs return: Float
    def on_float(node)
      assign node.children.first.to_f
    end

    # Processes a Rational node
    # @rbs node: AST::Node -- node to process
    # @rbs return: Rational
    def on_rational(node)
      assign Rational(node.children.first)
    end

    # Processes an imaginary node (Complex)
    # @rbs node: AST::Node -- node to process
    # @rbs return: Complex
    def on_imaginary(node)
      assign Complex(0, node.children.first.to_f)
    end

    # ..........................................................................
    # @!group Composite Data Types (Arrays, Hashes, Sets)
    # ..........................................................................

    # Processes an Array node
    # @rbs node: AST::Node -- node to process
    # @rbs return: Array
    def on_lbracket(node)
      assign([])
    end

    # Processes a Hash node
    # @rbs node: AST::Node -- node to process
    # @rbs return: Hash
    def on_lbrace(node)
      assign({})
    end

    # Process a label node (Hash key)
    # @rbs node: AST::Node -- node to process
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
  end
end
