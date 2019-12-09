# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/bundletool/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-bundletool'
  spec.version       = Fastlane::Bundletool::VERSION
  spec.author        = 'Martin Gonzalez'
  spec.email         = 'gonzalez.martin90@gmail.com'

  spec.summary       = 'Extracts a universal apk from an .aab file'
  spec.homepage      = "https://github.com/MartinGonzalez/fastlane-plugin-bundletool"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency('pry','~> 0.12.2')
  spec.add_development_dependency('bundler', '~> 2.0')
  spec.add_development_dependency('rspec', '~> 3.4')
  spec.add_development_dependency('rspec_junit_formatter', '~> 0.4.1')
  spec.add_development_dependency('rake', '~> 13.0')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools', '~> 0.1.2')
  spec.add_development_dependency('simplecov', '~> 0.12.0')
  spec.add_development_dependency('fastlane', '>= 2.137.0')
end