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

# 3) Foundational files (globals)
require_relative "lru_cache"
require_relative "mixins/composable"
require_relative "mixins/matchable"
require_relative "sigils"
require_relative "token"
require_relative "version"

# 3) Registries -- store of Procs that can be used with Fmt
require_relative "registries/registry" # base class
require_relative "registries/native_registry"
require_relative "registries/rainbow_registry"

# 4) Tokenizers -- lexical analysis of source code via Ripper
require_relative "tokenizers/tokenizer" # base class
require_relative "tokenizers/arguments_tokenizer"
require_relative "tokenizers/macro_tokenizer"

# 5) ASTs -- Abstract Syntax Trees (low level data structures)
require_relative "asts/arguments_ast"
require_relative "asts/macro_ast"
require_relative "asts/pipeline_ast"
require_relative "asts/procedure_ast"
require_relative "asts/token_ast"
require_relative "asts/template_ast"
require_relative "asts/root_ast"

# 6) Parsers -- String | Object parsers that generate ASTs
require_relative "parsers/parser" # base class
require_relative "parsers/arguments_parser"
require_relative "parsers/embed_parser"
require_relative "parsers/macro_parser"
require_relative "parsers/pipeline_parser"
require_relative "parsers/procedure_parser"
require_relative "parsers/template_parser"
require_relative "parsers/root_parser"

# 7) Models -- data structures build from ASTs
require_relative "models/arguments"
require_relative "models/macro"
require_relative "models/pipeline"
require_relative "models/procedure"
