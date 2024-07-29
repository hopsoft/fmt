# frozen_string_literal: true

require_relative "filter_group"

module Fmt
  class StringFilterGroup < FilterGroup
    def initialize
      super

      # rubocop:disable Layout/ExtraSpacing AllowForAlignment
      add :capitalize,        ->(s) { s.capitalize }
      add :chomp,             ->(s) { s.chomp }
      add :chop,              ->(s) { s.chop }
      add :downcase,          ->(s) { s.downcase }
      add :lstrip,            ->(s) { s.lstrip }
      add :reverse,           ->(s) { s.reverse }
      add :rstrip,            ->(s) { s.rstrip }
      add :shellescape,       ->(s) { s.shellescape }
      add :strip,             ->(s) { s.strip }
      add :succ,              ->(s) { s.succ }
      add :swapcase,          ->(s) { s.swapcase }
      add :undump,            ->(s) { s.undump }
      add :unicode_normalize, ->(s) { s.unicode_normalize }
      add :upcase,            ->(s) { s.upcase }
      # rubocop:enable Layout/ExtraSpacing AllowForAlignment
    end
  end
end
