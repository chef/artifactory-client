require 'pathname'
require 'artifactory/version'

module Artifactory
  autoload :Client,       'artifactory/client'
  autoload :Configurable, 'artifactory/configurable'
  autoload :Defaults,     'artifactory/defaults'
  autoload :Error,        'artifactory/errors'
  autoload :Util,         'artifactory/util'

  module Collection
    autoload :Artifact, 'artifactory/collections/artifact'
    autoload :Base,     'artifactory/collections/base'
  end

  module Resource
    autoload :Artifact,   'artifactory/resources/artifact'
    autoload :Base,       'artifactory/resources/base'
    autoload :Build,      'artifactory/resources/build'
    autoload :Group,      'artifactory/resources/group'
    autoload :Layout,     'artifactory/resources/layout'
    autoload :Plugin,     'artifactory/resources/plugin'
    autoload :Repository, 'artifactory/resources/repository'
    autoload :System,     'artifactory/resources/system'
    autoload :UrlBase,    'artifactory/resources/url_base'
    autoload :User,       'artifactory/resources/user'
  end

  class << self
    include Artifactory::Configurable

    #
    # The root of the Artifactory gem. This method is useful for finding files
    # relative to the root of the repository.
    #
    # @return [Pathname]
    #
    def root
      @root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    #
    # API client object based off the configured options in {Configurable}.
    #
    # @return [Artifactory::Client]
    #
    def client
      unless defined?(@client) && @client.same_options?(options)
        @client = Artifactory::Client.new(options)
      end

      @client
    end

    #
    # Delegate all methods to the client object, essentially making the module
    # object behave like a {Client}.
    #
    def method_missing(m, *args, &block)
      if client.respond_to?(m)
        client.send(m, *args, &block)
      else
        super
      end
    end

    #
    # Delegating +respond_to+ to the {Client}.
    #
    def respond_to_missing?(m, include_private = false)
      client.respond_to?(m) || super
    end
  end
end

# Load the initial default values
Artifactory.setup
