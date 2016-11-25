source 'https://rubygems.org'
gemspec

group :test do
  gem 'sinatra', '~> 1.4'
  gem 'rspec',   '~> 3.0'
  gem 'webmock', '~> 1.17'
  if RUBY_VERSION =~ /^1\.9\.3.*/
    # gaurd that webmock only brings in addressable with 1.9.3 support.
    gem 'addressable', '<= 2.4.0'
    # guard simplecov import of json gem
    gem 'json', '<= 1.8.3'
  end
  # rspec-mocks 3.4.1 breaks tests with 'System level too deep' errors.
  gem 'rspec-mocks', '3.4.0'
  gem 'simplecov'
  gem 'simplecov-console'
end
