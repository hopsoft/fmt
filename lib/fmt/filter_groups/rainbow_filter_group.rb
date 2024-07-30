# frozen_string_literal: true

require_relative "filter_group"

module Fmt
  # @note Rainbow filters convert the Object to a String
  class RainbowFilterGroup < FilterGroup
    def initialize
      super

      if defined? Rainbow
        safe_add :rainbow, ->(obj) { Rainbow obj } unless key?(:rainbow) # <- wraps object with Rainbow

        methods = Rainbow::Presenter.public_instance_methods(false).select do |method|
          Rainbow::Presenter.public_instance_method(method).arity == 0
        end

        method_names = methods
          .map { |m| m.name.to_sym }
          .concat(Rainbow::X11ColorNames::NAMES.keys)
          .sort

        method_names.each do |name|
          safe_add name, ->(obj) { Rainbow(obj).public_send name }
        end
      end
    rescue => error
      puts "Error adding Rainbow filters! #{error.inspect}"
    end
  end
end
