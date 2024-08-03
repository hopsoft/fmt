# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  module Sigils
    PREFIX = "%" # :: String

    KEY_PREFIXES = ["<", "{"].freeze # :: Array[String]

    KEY_SUFFIXES = [">", "}"].freeze # :: Array[String]

    ARGS_PREFIX = "(" # :: String

    ARGS_SUFFIX = ")" # :: String

    PIPE_OPERATOR = "|>" # :: String

    EMBED_PREFIX = "{{" # :: String

    EMBED_SUFFIX = "}}" # :: String
  end
end
