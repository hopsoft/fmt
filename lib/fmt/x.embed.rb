# frozen_string_literal: true

# rbs_inline: enabled

require "securerandom"

module Fmt
  class Embed
    HEAD = "{{"
    TAIL = "}}"

    # Initializes a Fmt::Embed instance
    # @rbs placeholder: String -- placeholder (i.e. {{%{name}red|bold}})
    # @rbs return: Fmt::Embed
    def initialize(placeholder)
      @placeholder = placeholder
    end

    attr_reader :placeholder # : String -- placeholder (i.e. {{%{name}red|bold}})
    attr_accessor :template # : Fmt::Template -- embed template (assign before calling format)

    # The placeholder regexp (i.e. /{{%{name}red\|bold}}/)
    # @rbs return: Regexp
    def placeholder_regexp
      /(?<head>#{HEAD})(?<head_space>\s*)#{template.placeholder_regexp}(?<tail_space>\s*)(?<tail>#{TAIL})/
    end

    # Template placeholder (i.e. %{name}red|bold)
    # @rbs return: String
    def template_placeholder
      placeholder.delete_prefix(HEAD).delete_suffix(TAIL)
    end

    # def format(**locals)
    #  $nate = 1
    #  formatted = template.format(**locals)
    #  binding.pry

    #  # binding.pry
    #  # t = TemplateScanner.new(template.placeholder).scan
    #  # t.format(template.placeholder, locals: {template.key => replacement})
    #  # binding.pry

    #  # locals[key] = template.format(template_string, locals: locals)
    #  # binding.pry
    #  # string.sub(placeholder_regexp, "#{head}#{key}#{tail}")
    # end
  end
end
