# frozen_string_literal: true

module Fmt
  class ProcTokenizer < Tokenizer
    # Constructor
    # @rbs lines: Array[String] | Enumerator[String] -- lines of source code to tokenize
    # @rbs return: Fmt::ProcTokenizer
    def initialize(*lines)
      super
      @lines = lines
    end

    attr_reader :lines    # :: Array[String] | Enumerator[String]

    # Tokenizes the lines of source code
    # @rbs return: Array[Object] -- tokens
    def tokenize
      catch :done do
        identifiers = 0
        beginners = 0
        finishers = 0

        lines.each do |line|
          Ripper.lex(line).each do |token|
            identifiers += 1 if proc_identifier?(token)
            beginners += 1 if proc_body_begin?(token)

            next unless identifiers.positive? || beginners.positive?
            tokens << token

            if proc_body_finish? token
              finishers += 1
              throw :done, tokens if finishers == beginners
            end
          end
        end
      end
    end
  end
end
