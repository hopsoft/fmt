# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Common Fmt sigils (used in String templates)
  class Sigils
    PREFIX = "%"                     # :: String -- template prefix
    KEY_PREFIXES = ["<", "{"].freeze # :: Array[String] -- named-template prefix
    KEY_SUFFIXES = [">", "}"].freeze # :: Array[String] -- named-template suffix
    ARGS_PREFIX = "("                # :: String -- macro arguments prefix
    ARGS_SUFFIX = ")"                # :: String -- macro arguments suffix
    PIPE_OPERATOR = "|>"             # :: String -- macro delimiter
    EMBED_PREFIX = "{{"              # :: String - embed prefix
    EMBED_SUFFIX = "}}"              # :: String - embed prefix
  end
end
