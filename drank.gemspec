# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drank/version'

Gem::Specification.new do |spec|
  spec.name          = "drank"
  spec.version       = Drank::VERSION
  spec.authors       = ["Joe Williams"]
  spec.email         = ["williams.joe@gmail.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # TODO lock down versions
  spec.add_runtime_dependency "excon", ">= 0"
  spec.add_runtime_dependency "zookeeper", ">= 0"
  spec.add_runtime_dependency "mixlib-cli", ">= 0"
  spec.add_runtime_dependency "mixlib-config", ">= 0"
  spec.add_runtime_dependency "mixlib-log", ">= 0"
  spec.add_runtime_dependency "yajl-ruby", ">= 0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
