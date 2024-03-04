lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "artifactory/version"

Gem::Specification.new do |spec|
  spec.name          = "artifactory"
  spec.version       = Artifactory::VERSION
  spec.author        = "Chef Release Engineering Team"
  spec.email         = "releng@chef.io"
  spec.description   = "A Ruby client for Artifactory"
  spec.summary       = "Artifactory is a simple, lightweight Ruby client for " \
                       "interacting with the Artifactory and Artifactory Pro " \
                       "APIs."
  spec.homepage      = "https://github.com/chef/artifactory-client"
  spec.license       = "Apache-2.0"

  spec.files         = %w{LICENSE} + Dir.glob("lib/**/*")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"
end
