# frozen_string_literal: true

require "forwardable"
require "strscan"

module Fmt
  class BaseScanner
    extend Forwardable

    def initialize(string)
      @scanner = StringScanner.new(string)
    end

    def_delegators :scanner, :string, :rest
    attr_reader :value

    def scan
      scanner.reset
      perform
    end

    # def substring
    # return nil unless match?
    # string[index..rindex]
    # end

    # def position
    # raise NotImplementedError
    # end

    # alias_method :pos, :position

    # def remainder
    # match? ? string[pos..] : string
    # end

    # def match?
    # index && rindex
    # end

    # private

    # def scan
    # @index = string.index(head)
    # @rindex = string.rindex(tail)
    # end

    protected

    attr_reader :scanner

    def perform
      raise NotImplementedError
    end
  end
end
