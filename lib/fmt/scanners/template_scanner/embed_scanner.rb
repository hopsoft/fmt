# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../base_scanner"
require_relative "../../embed"

module Fmt
  class TemplateScanner < BaseScanner
    class EmbedScanner < BaseScanner
      # Initializes a Fmt::EmbedScanner instance
      # @rbs string: String -- string to scan
      # @rbs root: Fmt::EmbedScanner -- root scanner
      def initialize(string, root: nil)
        super(string)
        @root ||= root || self
        @embeds = []
      end

      # All detected embeds
      # @rbs return: Array[Fmt::Embed]
      def embeds
        root? ? @embeds : root.embeds
      end

      protected

      attr_reader :root # : Fmt::EmbedScanner

      # Indicates if this is root scanner
      # @rbs return: bool
      def root?
        root == self
      end

      # Regexp that matches the head/start of an embed
      # @rbs return: Regexp
      def head
        /(?=#{Fmt::Embed::HEAD}[^{])\s*/o
      end

      # Regexp that matches the tail/end of an embed
      # @rbs return: Regexp
      def tail
        /\s*[^}]+#{Fmt::Embed::TAIL}/o
      end

      # 1) Performs the scan
      # 2) Extacts the embed value
      # 3) Builds a list of Fmt::Embed instances (stored on the root scanner)
      # @rbs return: String -- embed string
      def perform
        return unless string.include?(Fmt::Embed::HEAD)
        string_scanner.skip_until(head) # <------------ advance to start
        @value = string_scanner.scan_until(tail) # <- extract placeholder

        if value
          embeds.prepend Fmt::Embed.new(value, string: string)
          scanner = EmbedScanner.new(current_string, root: root)
          while scanner.scan
            scanner = EmbedScanner.new(scanner.current_string, root: root)
          end
        end

        value
      end
    end
  end
end
