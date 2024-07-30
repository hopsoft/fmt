# frozen_string_literal: true

require_relative "filter_group"

module Fmt
  class StringFilterGroup < FilterGroup
    def initialize
      super

      # rubocop:disable Layout/ExtraSpacing AllowForAlignment
      add :capitalize,        ->(obj) { obj.to_s.capitalize }
      add :chomp,             ->(obj) { obj.to_s.chomp }
      add :chop,              ->(obj) { obj.to_s.chop }
      add :downcase,          ->(obj) { obj.to_s.downcase }
      add :lstrip,            ->(obj) { obj.to_s.lstrip }
      add :reverse,           ->(obj) { obj.to_s.reverse }
      add :rstrip,            ->(obj) { obj.to_s.rstrip }
      add :shellescape,       ->(obj) { obj.to_s.shellescape }
      add :strip,             ->(obj) { obj.to_s.strip }
      add :succ,              ->(obj) { obj.to_s.succ }
      add :swapcase,          ->(obj) { obj.to_s.swapcase }
      add :undump,            ->(obj) { obj.to_s.undump }
      add :unicode_normalize, ->(obj) { obj.to_s.unicode_normalize }
      add :upcase,            ->(obj) { obj.to_s.upcase }
      # rubocop:enable Layout/ExtraSpacing AllowForAlignment
    end
  end
end
