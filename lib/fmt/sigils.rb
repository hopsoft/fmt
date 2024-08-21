# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Common Fmt sigils (used in String templates)
  class Sigils
    # Native Ruby format specifiers
    # @see https://docs.ruby-lang.org/en/master/format_specifications_rdoc.html
    FORMAT_SPECIFIERS = %w[A E G X a b c d e f g i o p s u x].freeze # :: Array[String] -- native Ruby format specifiers
    FORMAT_PREFIX = "%"                                              # :: String        -- start of a format string (i.e. a template)
    FORMAT_METHOD = :sprintf                                         # :: Symbol        -- format method name
    NAME_PREFIXES = ["<", "{"].freeze                                # :: Array[String] -- named-template prefix
    NAME_SUFFIXES = [">", "}"].freeze                                # :: Array[String] -- named-template suffix
    ARGS_PREFIX = "("                                                # :: String        -- macro arguments prefix
    ARGS_SUFFIX = ")"                                                # :: String        -- macro arguments suffix
    PIPE_OPERATOR = "|>"                                             # :: String        -- macro delimiter
    EMBED_PREFIX = "{{"                                              # :: String        -- embed prefix
    EMBED_SUFFIX = "}}"                                              # :: String        -- embed prefix
  end
end
