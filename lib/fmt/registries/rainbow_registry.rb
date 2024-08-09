# frozen_string_literal: true

# rbs_inline: enabled

require_relative "registry"

module Fmt
  # Extends native Ruby String format specifications with Rainbow methods
  # @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
  # @note Rainbow macros convert the Object to a String
  class RainbowRegistry < Registry
    def initialize
      super

      if defined? Rainbow
        add(:rainbow) { |obj| Rainbow obj }

        methods = Rainbow::Presenter.public_instance_methods(false).select do |method|
          Rainbow::Presenter.public_instance_method(method).arity == 0
        end

        method_names = methods
          .map { |m| m.name.to_sym }
          .concat(Rainbow::X11ColorNames::NAMES.keys)
          .sort

        method_names.each do |name|
          add(name) { |obj| Rainbow(obj).public_send name }
        end
      end
    rescue => error
      puts "Error adding Rainbow filters! #{error.inspect}"
    end
  end
end
