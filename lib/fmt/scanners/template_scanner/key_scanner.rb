# frozen_string_literal: true

# rbs_inline: enabled

require_relative "../base_scanner"
require_relative "../../template"

module Fmt
  class TemplateScanner < BaseScanner
    class KeyScanner < BaseScanner
      protected

      # Regexp that matches the head/start of a template key
      # @rbs return: Regexp
      def head
        Regexp.new Fmt::Template::HEAD
      end

      # Regexp that matches the tail/end of a template key
      # @rbs return: Regexp
      def tail
        Regexp.new Fmt::Template::TAIL
      end

      # 1) Performs the scan
      # 2) extracts the value
      # 3) advances the scanner to the end of the template (properly sets current_string)
      # @rbs return: Symbol? -- matched template key (if found)
      def perform
        string_scanner.skip_until(head) # <------------- 1) advance to head

        if string_scanner.matched?
          string_scanner.skip(/\s*/) # <---------------- 2) skip whitespace
          @value = string_scanner.scan(/\w+/) # <------- 3) extract value
          string_scanner.skip(/\s*/) if value # <------- 4) skip whitespace
          string_scanner.skip_until(tail) if value # <-- 5) advance to tail
        end

        @value = value&.strip&.to_sym
      end
    end
  end
end
