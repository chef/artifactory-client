# Artifactory Client

[![Build status](https://badge.buildkite.com/a5156457906e25cbde53c408598d233a202c675c670f4c768d.svg?branch=master)](https://buildkite.com/chef-oss/chef-artifactory-client-master-verify)
[![Gem Version](http://img.shields.io/gem/v/artifactory.svg)][gem]

A Ruby client and interface to the Artifactory API. **The majority of API endpoints are only exposed for Artifactory Pro customers!** As such, many of the resources and actions exposed by this gem also require Artifactory Pro.

The Artifactory gem offers a convienent interface for managing various parts of the Artifactory API. It is not a complete API implementation, and should still be considered a work in progress.

Quick start
-----------
Install via Rubygems:

    $ gem install artifactory

or add it to your Gemfile if you're using Bundler:

```ruby
gem 'artifactory', '~> 3.0.5'
```

In your library or project, you wil likely want to include the `Artifactory::Resource` namespace:

```ruby
include Artifactory::Resource
```

This will given you "Rails-like" access to the top-level Artifactory resources like:

```ruby
System.info
Repository.all
```

If you choose not to include the module (for namespacing reasons), you will need to specify the full module path to access resources:

```ruby
Artifactory::Resource::System.info
Artifactory::Resource::Repository.all
```

### Create a connection
Before you can make a request, you must give Artifactory your connection information.

```ruby
Artifactory.configure do |config|
  # The endpoint for the Artifactory server. If you are running the "default"
  # Artifactory installation using tomcat, don't forget to include the
  # +/artifactoy+ part of the URL.
  config.endpoint = 'https://my.storage.server/artifactory'

  # The basic authentication information. Since this uses HTTP Basic Auth, it
  # is highly recommended that you run Artifactory over SSL.
  config.username = 'admin'
  config.password = 'password'

  # You can also use an API key for authentication, username and password
  # take precedence so leave them off if you are using an API key.
  config.api_key = 'XXXXXXXXXXXXXXXXXX'

  # Speaking of SSL, you can specify the path to a pem file with your custom
  # certificates and the gem will wire it all up for you (NOTE: it must be a
  # valid PEM file).
  config.ssl_pem_file = '/path/to/my.pem'

  # Or if you are feelying frisky, you can always disable SSL verification
  config.ssl_verify = false

  # You can specify any proxy information, including any authentication
  # information in the URL.
  config.proxy_username = 'user'
  config.proxy_password = 'password'
  config.proxy_address  = 'my.proxy.server'
  config.proxy_port     = '8080'
end
```

All of these parameters are also configurable via the top-level `Artifactory` object. For example:

```ruby
Artifactory.endpoint = '...'
```

Or, if you want to be really Unixy, these parameters are all configurable via environment variables:

```bash
# Artifactory will use these values for the defaults
export ARTIFACTORY_ENDPOINT=http://my.storage.server/artifactory
export ARTIFACTORY_USERNAME=admin
export ARTIFACTORY_PASSWORD=password
export ARTIFACTORY_API_KEY=XXXXXXXXXXXXXXXXXX
export ARTIFACTORY_SSL_PEM_FILE=/path/to/my.pem
```

You can also create a full `Client` object with hash parameters:

```ruby
client = Artifactory::Client.new(endpoint: '...', username: '...')
```

### Making requests
The Artifactory gem attempts to make the Artifactory API as object-oriented and Ruby-like as possible. All of the methods and API calls are heavily documented with examples inline using YARD. In order to keep the examples versioned with the code, the README only lists a few examples for using the Artifactory gem. Please see the inline documentation for the full API documentation. The tests in the 'spec' directory are an additional source of examples.

#### Artifacts
```ruby
# Upload an artifact to a repository whose key is 'repo_key'
artifact.upload('/local/path/to/file', 'repo_key', param_1: 'foo')

# Search for an artifact by name
artifact = Artifact.search(name: 'package.deb').first
artifact #=> "#<Artifactory::Resource::Artifact md5: 'ABCD1234'>"

# Get the properties of an artifact
artifact.md5 #=> "ABCD1234"
artifact.properties #=> { ... }
# Set the properties of an artifact
artifact.properties({prop1: 'value1', 'prop2': 'value2'}) #=> { ... }

# Download the artifact to disk
artifact.download #=> /tmp/folders-a38b0decf038201/package.deb
artifact.download('~/Desktop', filename: 'software.deb') #=> /Users/you/Desktop/software.deb

# Delete the artifact from the Artifactory server
artifact.delete #=> true
```

#### Builds
```ruby
# Show all components
BuildComponent.all #=> [#<BuildComponent ...>]

# Show all builds for a components
Build.all('wicket') #=> [#<Build ...>]

# Find a build component by name
component = BuildComponent.find('wicket')

# Delete some builds for a component
component.delete(build_numbers: %w( 51 52)) #=> true

# Delete all builds for a component
component.delete(delete_all: true) #=> true

# Delete a component and all of its associated data (including artifacts)
component.delete(artifacts: true, delete_all: true) #=> true

# Get a list of all buld records for a component
component.builds #=> #=> [#<Artifactory::Resource::Build ...>, ...]

# Create a new build record
build = Build.new(name: 'fricket', number: '51', properties: {...}, modules: [...])
build.save

# Find a build
build = Build.find('wicket', '51')

# Promote a build
build.promote('libs-release-local', status: 'staged', comment: 'Tested on all target platforms.')
```

#### Plugins
```ruby
# Show all plugins
Plugin.all #=> [#<Plugin ...>]
```

#### Repository
```ruby
# Find a repository by name
repo = Repository.find(name: 'libs-release-local')
repo #=> #<Artifactory::Resource::Repository ...>

# Get information about the repository
repo.description => "The default storage mechanism for..."

# Change the repository
repo.description = "This is a new description"
repo.save

# Upload an artifact to the repo
repo.upload('/local/path/to/file', param_1: 'foo', param_2: 'bar')

# Get a list of artifacts in this repository
repo.artifacts #=> [#<Artifactory::Resource::Artifact ...>, ...]
```

#### System
```ruby
# Get the system information
System.info #=> "..."

# See if artifactory is running
System.ping #=> true

# Get the Artifactory server version and other information
System.version #=> { ... }
```

#### Raw requests
If there's a specific endpoint or path you need to hit that is not implemented by this gem, you can execute a "raw" request:

```ruby
# Using the top-level Artifactory module
Artifactory.get('/some/special/path', param_1: 'foo', param_2: 'bar')

# Using an Artifactory::Client object
client.get('/some/special/path', param_1: 'foo', param_2: 'bar')
```

For more information on the methods available, please see the [`Artifactory::Client` class](https://github.com/opscode/artifactory-client/blob/master/lib/artifactory/client.rb).

### Threadsafety
If you plan to use the Artifactory gem in a library, you should be aware that _certain_ pathways for accessing resources are **not** threadsafe. In order to deliver a "Rails-like" experience, accessing a resource without a client object uses a global shared state. Other threads may modify this state, and therefore we do **not** recommend using the Rails-like approach if you are concerned about threadsafety. The following code snippet may better explain the differences:

```ruby
# In our current thread...
Artifactory.endpoint = 'http://foo.com/artifactory'

# Meanwhile, in another thread...
Thread.new do
  Artifactory.endpoint = 'http://bar.com/artifactory'
end

# You have a 50/50 chance of which endpoint is used, depending on the order in
# which the threads execute on the CPU.
Artifactory.endpoint #=> 'http://foo.com/artifactory'
Artifactory.endpoint #=> 'http://bar.com/artifactory'
```

To avoid this potential headache, the Artifactory gem offers a less Rails-like API in which the `Artifactory::Client` object becomes the pivot for all resources. First, you must create a client object (you cannot use the global namespace):

```ruby
client = Artifactory::Client.new(endpoint: 'http://foo.com/artifactory')
```

And then execute all requests using this client object, with the general pattern `resource_method`:

```ruby
# Search for artifacts
client.artifact_search(name: '...') #=> [...]

# Get all plugins
client.all_plugins #=> [...]
```

This pattern is slightly less eye-appealing, but it will ensure that your code is threadsafe.

Development
-----------
1. Clone the project on GitHub
2. Create a feature branch
3. Submit a Pull Request

Artifactory uses a built-in Sinatra server that "acts like" a real Artifactory Pro server. Since we cannot bundle a full Artifactory Pro server with the gem, we have re-implemented various pieces of their API. If you are writing a feature that accesses a new endpoint, you will likely need to add that endpoint to the vendored Sinatra app, using the [API documentation for Artifactory](http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API).

Important Notes:

- **All new features must include test coverage.** At a bare minimum, Unit tests are required. It is preferred if you include acceptance tests as well.
- **The tests must be be idempotent.** The HTTP calls made during a test should be able to be run over and over.
- **Tests are order independent.** The default RSpec configuration randomizes the test order, so this should not be a problem.

## Maintainer

This project is maintained by Chef's Release Engineering Team (releng@chef.io).

## License

```text
Copyright 2013-2019 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[gem]: https://rubygems.org/gems/artifactory
