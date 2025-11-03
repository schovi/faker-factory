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

  # # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").
                                         reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "5.8.4"
  spec.add_development_dependency 'minitest-reporters', '1.1.8'
  spec.add_development_dependency 'minitest-ci', '3.0.3'
  spec.add_development_dependency 'guard', '2.13.0'
  spec.add_development_dependency 'guard-minitest', '2.4.4'
  spec.add_development_dependency 'terminal-notifier-guard', '1.7.0'
  spec.add_development_dependency 'pry', '0.10.3'

  spec.add_runtime_dependency 'faker'
end
