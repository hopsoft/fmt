# frozen_string_literal: true

# 1) Standard libraries
require "date"
require "forwardable"
require "monitor"
require "ripper"
require "set"
require "singleton"
require "strscan"

# 2) 3rd party libraries
require "ast"

# 1) Foundational files (globals)
require_relative "lru_cache"
require_relative "mixins/pattern_matchable"
require_relative "sigils"
require_relative "version"

# 2) Registries -- store of Procs that can be used with Fmt
require_relative "registries/registry" # base class
require_relative "registries/native_registry"
require_relative "registries/rainbow_registry"

# 3) TokenModel -- wrapper for Ripper tokens (simplifies tokenization)
require_relative "models/token_model"

# 4) Tokenizers -- lexical analysis of source code via Ripper
require_relative "tokenizers/tokenizer" # base class
require_relative "tokenizers/arguments_tokenizer"
require_relative "tokenizers/macro_tokenizer"

# ASTs -- Abstract Syntax Trees (low level data structures)
require_relative "asts/arguments_ast"
require_relative "asts/macro_ast"
require_relative "asts/pipeline_ast"
require_relative "asts/proc_ast"
require_relative "asts/token_ast"

# Processors -- AST processors (used for Model construction)
require_relative "processors/arguments_processor"
require_relative "processors/macro_processor"
require_relative "processors/pipeline_processor"
require_relative "processors/proc_processor"

# Parsers -- String | Object parsers that generate ASTs
require_relative "parsers/parser" # base class
require_relative "parsers/arguments_parser"
require_relative "parsers/embed_parser"
require_relative "parsers/macro_parser"
require_relative "parsers/pipeline_parser"
require_relative "parsers/proc_parser"

# Models -- high level data structures
require_relative "models/arguments_model"
require_relative "models/macro_model"
require_relative "models/pipeline_model"
require_relative "models/proc_model"
