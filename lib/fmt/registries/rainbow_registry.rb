# frozen_string_literal: true

# rbs_inline: enabled

module Fmt
  # Extends native Ruby String format specifications with Rainbow methods
  # @see https://ruby-doc.org/3.3.4/format_specifications_rdoc.html
  # @note Rainbow macros convert the Object to a String
  class RainbowRegistry < Registry
    # Constructor
    def initialize
      super

      if defined? Rainbow
        add([Object, :rainbow]) { Rainbow self }
        add([Object, :bg]) { |*args, **kwargs| Rainbow(self).bg(*args, **kwargs) }
        add([Object, :color]) { |*args, **kwargs| Rainbow(self).color(*args, **kwargs) }

        methods = Rainbow::Presenter.public_instance_methods(false).select do
          Rainbow::Presenter.public_instance_method(_1).arity == 0
        end

        method_names = methods
          .map { _1.name.to_sym }
          .concat(Rainbow::X11ColorNames::NAMES.keys)
          .sort

        method_names.each do |name|
          add([Object, name]) { Rainbow(self).public_send name }
        end
      end
    rescue => error
      puts "#{self.class.name} - Error adding filters! #{error.inspect}"
    end
  end
end
