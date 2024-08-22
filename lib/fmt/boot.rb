# frozen_string_literal: true

# Standard libraries
require "date"
require "forwardable"
require "monitor"
require "ripper"
require "set"
require "singleton"
require "strscan"

# 3rd party libraries
require "ast"

# Foundational files (globals)
require_relative "lru_cache"
require_relative "mixins/matchable"
require_relative "node"
require_relative "renderer"
require_relative "sigils"
require_relative "token"
require_relative "tokenizer"
require_relative "version"

# Registries -- store of Procs that can be used with Fmt
require_relative "registries/registry" # <- base class
require_relative "registries/native_registry"
require_relative "registries/rainbow_registry"

# Parsers -- String | Object parsers that generate ASTs
require_relative "parsers/parser" # <- base class
require_relative "parsers/arguments_parser"
require_relative "parsers/embeds_parser"
require_relative "parsers/macro_parser"
require_relative "parsers/pipeline_parser"
require_relative "parsers/template_parser"

# Models -- data structures build from ASTs
require_relative "models/model" # <- base class
require_relative "models/arguments"
require_relative "models/macro"
require_relative "models/pipeline"
require_relative "models/template"
