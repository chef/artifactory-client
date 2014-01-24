# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'artifactory/version'

Gem::Specification.new do |spec|
  spec.name          = 'artifactory'
  spec.version       = Artifactory::VERSION
  spec.author        = 'Seth Vargo'
  spec.email         = 'sethvargo@gmail.com'
  spec.description   = %q|A Ruby interface for Artifactory|
  spec.summary       = %q|A Ruby interface for Artifactory|
  spec.homepage      = 'https://github.com/opscode/artifactory-client'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'httpclient', '~> 2.3'
  spec.add_dependency 'i18n',       '~> 0.5'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sinatra',   '~> 1.4'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov', '~> 0.8'
  spec.add_development_dependency 'rspec',     '~> 2.14'
  spec.add_development_dependency 'webmock',   '~> 1.17'
end
