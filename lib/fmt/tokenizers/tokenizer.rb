# frozen_string_literal: true

require "ast"
require "ripper"

module Fmt
  # Ruby source code token extractor
  #
  # Uses Ripper from Ruby's standard library
  # @see https://rubyapi.org/3.4/o/ripper
  #
  # Ripper.lex cheatsheet: @see doc/lexer.md
  #
  # @example Ripper token
  #   [[lineno, column], type, token, state]
  #
  class Tokenizer
    # Constructor
    # @rbs return: Fmt::Tokenizer
    def initialize(...)
      @tokens = []
    end

    attr_reader :tokens # :: Array[Object] -- result of tokenization

    # Tokenizes the value(s) passed to the constructor
    # @note Should assign @tokens
    def tokenize
      raise NotImplementedError, "Must be implemented by subclass"
    end

    # Converts the result of tokenization to an AST
    # @rbs return: AST::Node
    def to_ast
      raise NotImplementedError, "Must be implemented by subclass"
    end

    protected

    # Builds an AST node
    # @rbs type: Symbol -- node type
    # @rbs children: Array[Object] -- node children
    # @rbs properties: Hash[Symbol, Object] -- node properties
    # @rbs return: AST::Node
    def ast_node(type, *children, **properties)
      AST::Node.new type, children, properties
    end

    # Converts the tokenized Ripper tokens to an AST
    # @example [[lineno, column], type, token, state]
    # @rbs return: Array[AST::Node]
    def tokens_to_ast
      node = ast_node(:tokens)
      tokens.each do |token|
        (_lineno, _column), type, tok, _state = token
        child = ast_node(type.to_s.delete_prefix("on_").to_sym, tok)
        node = node.append(child) # @note AST::Nodes are immutable, so we reassign
      end
      node
    end

    # Builds a source string from the tokenized Ripper tokens
    # @example [[lineno, column], type, token, state]
    # @rbs return: String
    def tokens_to_source
      tokens.map { |token| token[2] }.join
    end

    # Indicates if the token is a String
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: bool
    def string?(token)
      case token
      in [_, :on_tstring_content, _, _] then true
      else false
      end
    end

    ## Type casts the token to a supported primitive
    ## @rbs token: [[Integer, Integer], Symbol, String, Object]
    ## @rbs return: String | Symbol | Integer | Float | Rational | Complex | bool | nil
    # def cast_primitive(token)
    #  # rubocop:disable Layout/ExtraSpacing
    #  case token
    #  in [_, :on_tstring_content, value, _]        then value                  # 01) String
    #  in [_, :on_symbol, value, _]                 then value.to_sym           # 02) Symbol
    #  in [_, :on_int, value, _]                    then value.to_i             # 03) Integer
    #  in [_, :on_kw, value, _] if value == "false" then false                  # 04) Boolean
    #  in [_, :on_kw, value, _] if value == "true"  then true                   # 05) Boolean
    #  in [_, :on_kw, value, _] if value == "nil"   then nil                    # 06) Nil
    #  in [_, :on_float, value, _]                  then value.to_f             # 07) Float
    #  in [_, :on_rational, value, _]               then Rational(value)        # 08) Rational
    #  in [_, :on_imaginary, value, _]              then Complex(0, value.to_f) # 09) Complex
    #  end
    #  # rubocop:enable Layout/ExtraSpacing
    # end

    # # Indicates if the token is a supported primitive
    # # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # # @rbs return: bool
    # def primitive?(token)
    #   # rubocop:disable Layout/ExtraSpacing
    #   case token
    #   in [_, :on_tstring_content, value, _]        then true # 01) String
    #   in [_, :on_symbol, value, _]                 then true # 02) Symbol
    #   in [_, :on_int, value, _]                    then true # 03) Integer
    #   in [_, :on_kw, value, _] if value == "false" then true # 04) Boolean
    #   in [_, :on_kw, value, _] if value == "true"  then true # 05) Boolean
    #   in [_, :on_kw, value, _] if value == "nil"   then true # 06) Nil
    #   in [_, :on_float, value, _]                  then true # 07) Float
    #   in [_, :on_rational, value, _]               then true # 08) Rational
    #   in [_, :on_imaginary, value, _]              then true # 09) Complex
    #   else false
    #   end
    #   # rubocop:enable Layout/ExtraSpacing
    # end

    # Indicates if the token begins arguments for a method definition or call
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: bool
    def arguments_begin?(token)
      case token
      in [_, :on_lparen, _, _] then true
      else false
      end
    end

    # Indicates if the token finishes arguments for a method definition or call
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: bool
    def arguments_finish?(token)
      case token
      in [_, :on_rparen, _, _] then true
      else false
      end
    end

    # # Indicates if the token begins a supported composite literal (i.e. Array or Hash)
    # # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # # @rbs return: bool
    # def composite_begin?(token)
    #   case token
    #   in [_, :on_lbracket | :on_lbrace, _, _] then true
    #   else false
    #   end
    # end

    # # Indicates if the Ripper token finishes a supported composite literal (i.e. Array or Hash)
    # # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # # @rbs return: bool
    # def composite_finish?(token)
    #   case token
    #   in [_, :on_rbracket | :on_rbrace, _, _] then true
    #   else false
    #   end
    # end

    # Indicates if the Ripper token begins a Regexp literal
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def regexp_begin?(token)
      case token
      in [_, :on_regexp_beg, _, _] then true
      else false
      end
    end

    # Indicates if the Ripper token finishes a Regexp literal
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def regexp_finish?(token)
      case token
      in [_, :on_regexp_end, _, _] then true
      else false
      end
    end

    # Indicates if the Ripper token is a Proc identifier
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def proc_identifier?(token)
      # rubocop:disable Layout/ExtraSpacing
      case token
      in [_, :on_const, token, _] if token == "Proc"   then true
      in [_, :on_ident, token, _] if token == "proc"   then true
      in [_, :on_ident, token, _] if token == "lambda" then true
      else false
      end
      # rubocop:enable Layout/ExtraSpacing
    end

    # Indicates if the Ripper token begins a Proc definition
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def proc_body_begin?(token)
      # rubocop:disable Layout/ExtraSpacing
      case token
      in [_, :on_tlambda, _, _]                        then true
      in [_, :on_kw, token, _]    if token == "do"     then true
      in [_, :on_lbrace, _, _]                         then true
      else false
      end
      # rubocop:enable Layout/ExtraSpacing
    end

    # Indicates if the Ripper token finishes a Proc definition
    # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # @rbs return: Boolean
    def proc_body_finish?(token)
      # rubocop:disable Layout/ExtraSpacing
      case token
      in [_, :on_kw, token, _ ] if token == "end" then true
      in [_, :on_rbrace, _, _]                    then true
      else false
      end
      # rubocop:enable Layout/ExtraSpacing
    end

    # # Extracts Proc tokens from Ripper token
    # #
    # # @note Prepends ["proc", " "] if the Proc was defined as a Ruby block
    # #       Supports reconstructing the Proc from the AST later if needed
    # #
    # # @rbs token: [[Integer, Integer], Symbol, String, Object]
    # # @rbs return: Array[String]
    # def proc_tokens(token)
    #   # rubocop:disable Layout/ExtraSpacing
    #   case token
    #   in [_, :on_kw, token, _] if token == "do" then ["proc", " ", token]
    #   in [_, :on_lbrace, token, _]              then ["proc", " ", token]
    #   in [_, _, token, _]                       then [token]
    #   end
    #   # rubocop:enable Layout/ExtraSpacing
    # end

    ## Indicates if the token is a Hash key
    ## @rbs token: [[Integer, Integer], Symbol, String, Object]
    ## @rbs return: bool
    # def hash_key?(token)
    #  case token
    #  in [_, :on_label, _, _] then true
    #  else false
    #  end
    # end
  end
end
