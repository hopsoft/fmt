# frozen_string_literal: true

require_relative "base_scanner"
require_relative "../embed"

module Fmt
  class EmbedScanner < BaseScanner
    def initialize(string, root: nil)
      super(string)
      @root ||= root || self
      @embeds = []
    end

    def embeds
      root? ? @embeds : root.embeds
    end

    attr_reader :root

    def root?
      root == self
    end

    protected

    def includes_embed?(string)
      string.match?(/[{]{2}/)
    end

    def next_scanner(string)
      Fmt::EmbedScanner.new string, root: root
    end

    def scan_embeds(string)
      return unless includes_embed?(string)

      string = string[string.index(/[{]{2}/) + 2..]
      scanner = next_scanner(string)
      while (embed = scanner.scan)
        embeds << Fmt::Embed.new(embed)
        scanner = next_scanner(scanner.rest)
      end
    end

    def perform?
      !string.start_with?("}")
    end

    def perform
      return unless perform?
      scan_embeds string # <------------------------------------ extract embeds
      string_scanner.scan_until(/[{]{2}/) # <------------------- advance to start
      @value = string_scanner.scan_until(/[^}]*(?=[}]{2})/) # <- extract value
    end
  end
end
