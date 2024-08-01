# frozen_string_literal: true

# rbs_inline: enabled

require_relative "base_scanner"
require_relative "template_scanner/embed_scanner"
require_relative "template_scanner/filter_scanner"
require_relative "template_scanner/key_scanner"
require_relative "../template"

module Fmt
  class TemplateScanner < BaseScanner
    protected

    # 1) Performs the scan
    # 2) Extracts the template components (embeds, key, filters)
    # 3) Builds a Fmt::Template instance
    # @rbs return: Fmt::Template?
    def perform
      # 1) extract embeds
      embed_scanner = EmbedScanner.new(string)
      embed_scanner.scan
      embed_scanner.embeds.each do |embed|
        embed.template = TemplateScanner.new(embed.template_string).scan
      end

      # 2) extract key
      key_scanner = KeyScanner.new(string)
      key = key_scanner.scan

      return nil unless key

      # 3) extract filters
      filter_scanner = FilterScanner.new(key_scanner.current_string)
      filters = filter_scanner.scan

      @value = Fmt::Template.new(key, *filters, embeds: embed_scanner.embeds, string: string)
    end
  end
end
