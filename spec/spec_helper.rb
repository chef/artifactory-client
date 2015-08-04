require 'bundler/setup'
require 'rspec'
require 'webmock/rspec'

# Require our main library
require 'artifactory'

# Require helpers
require_relative 'support/api_server'

RSpec.configure do |config|
  # Custom helper modules and extensions

  # Prohibit using the should syntax
  config.expect_with :rspec do |spec|
    spec.syntax = :expect
  end

  # Allow tests to isolate a specific test using +focus: true+. If nothing
  # is focused, then all tests are executed.
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # Stuff to do on each run
  config.before(:each) { Artifactory.reset! }
  config.after(:each)  { Artifactory.reset! }

  config.before(:each, :integration) do
    Artifactory.endpoint = 'http://localhost:8889'
    Artifactory.username = nil
    Artifactory.password = nil
    stub_request(:any, /#{Artifactory.endpoint}/).to_rack(Artifactory::APIServer)
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
