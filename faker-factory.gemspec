# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faker_factory/version'

Gem::Specification.new do |spec|
  spec.name          = "faker-factory"
  spec.version       = FakerFactory::VERSION
  spec.authors       = ["David Schovanec"]
  spec.email         = ["schovanec@schovi.cz"]

  spec.summary       = %q{Universal random data generator}
  spec.description   = %q{Universal random data generator. Supports String, Array, Hash, repeat and conditional parts}
  spec.homepage      = "https://github.com/schovi/faker-factory"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files         = `git ls-files -z`.split("\x0").
                                        reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.0"
  spec.add_development_dependency "pry", "~> 0.14"

  spec.add_runtime_dependency "faker", ">= 2.0"
end
