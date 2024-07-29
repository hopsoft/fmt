# frozen_string_literal: true

module Fmt
  class Embed
    def initialize(string)
      @string = string
    end

    attr_reader :string

    def placeholder
      "{{#{string}}}"
    end

    def format(**locals)
      Fmt(string, **locals)
    end
  end
end
