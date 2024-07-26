# frozen_string_literal: true

require_relative "lib/fmt/version"

Gem::Specification.new do |s|
  s.name = "fmt"
  s.version = Fmt::VERSION
  s.authors = ["Nate Hopkins (hopsoft)"]
  s.email = ["natehop@gmail.com"]

  s.summary = "A simple template engine based on native Ruby String formatting mechanics"
  s.description = s.summary
  s.homepage = "https://github.com/hopsoft/fmt"
  s.license = "MIT"
  s.required_ruby_version = ">= 3.0.0"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = s.homepage

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.add_development_dependency "amazing_print"
  s.add_development_dependency "magic_frozen_string_literal"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "rainbow"
  s.add_development_dependency "rake"
  s.add_development_dependency "tocer"
  s.add_development_dependency "yard"
end
