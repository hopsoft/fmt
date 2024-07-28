# frozen_string_literal: true

Dir[File.join(__dir__, "scanners", "*.rb")].each { |file| require file }
