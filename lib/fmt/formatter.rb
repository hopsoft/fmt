# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  class Formatter
    # include Singleton

    # attr_reader :filters

    # def add_rainbow_filters
    #   filters.merge! Fmt::RainbowFilterGroup.new
    # end

    # def add_filter(...)
    #   filters.add(...)
    # end

    # def delete_filter(...)
    #   filters.delete(...)
    # end

    # def format(string, fmt: {}, **locals)
    #   filters.with_overrides fmt do
    #     result = string.to_s
    #     template = Fmt::TemplateScanner.new(result).scan

    #     while template
    #       result = template.format(result, **locals)
    #       template = Fmt::TemplateScanner.new(result).scan
    #     end

    #     result
    #   end
    # end

    # private

    # def initialize
    #   super
    #   @filters = Fmt::NativeFilterGroup.new
    # end
  end
end
