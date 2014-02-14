# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'artifactory/version'

Gem::Specification.new do |spec|
  spec.name          = 'artifactory'
  spec.version       = Artifactory::VERSION
  spec.author        = 'Seth Vargo'
  spec.email         = 'sethvargo@gmail.com'
  spec.description   = 'A Ruby client for Artifactory'
  spec.summary       = 'Artifactory is a simple, lightweight Ruby client for ' \
                       'interacting with the Artifactory and Artifactory Pro ' \
                       'APIs.'
  spec.homepage      = 'https://github.com/opscode/artifactory-client'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
