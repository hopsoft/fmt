# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Common Fmt sigils (used in String templates)
  class Sigils
    # Native Ruby format specifiers
    # @see https://docs.ruby-lang.org/en/master/format_specifications_rdoc.html
    FORMAT_SPECIFIERS = %w[A E G X a b c d e f g i o p s u x].freeze # :: Array[String] -- format specifiers
    FORMAT_PREFIX = "%"              # :: String -- template prefix
    FORMAT_METHOD = :sprintf         # :: Symbol -- format method name
    KEY_PREFIXES = ["<", "{"].freeze # :: Array[String] -- named-template prefix
    KEY_SUFFIXES = [">", "}"].freeze # :: Array[String] -- named-template suffix
    ARGS_PREFIX = "("                # :: String -- macro arguments prefix
    ARGS_SUFFIX = ")"                # :: String -- macro arguments suffix
    PIPE_OPERATOR = "|>"             # :: String -- macro delimiter
    EMBED_PREFIX = "{{"              # :: String - embed prefix
    EMBED_SUFFIX = "}}"              # :: String - embed prefix
  end
end
