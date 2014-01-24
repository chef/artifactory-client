require 'httpclient'
require 'json'
require 'rexml/document'
require 'uri'

module Artifactory
  #
  # Client for the Artifactory API.
  #
  # @see http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API
  #
  class Client
    class << self
      #
      # @private
      #
      # @macro proxy
      #   @method $1
      #     Get a proxied collection for +$1+. The proxy automatically injects
      #     the current client into the $2, providing a very Rubyesque way for
      #     handling multiple connection objects.
      #
      #     @example Get the $1 from the client object
      #       client = Artifactory::Client.new('...')
      #       client.$1 #=> $2 (with the client object pre-populated)
      #
      #     @return [Artifactory::Proxy<$2>]
      #       a collection proxy for the $2
      #
      def proxy(name, klass)
        class_eval <<-EOH, __FILE__, __LINE__ + 1
          def #{name}
            @#{name} ||= Artifactory::Proxy.new(self, #{klass})
          end
        EOH
      end
    end

    include Artifactory::Configurable

    proxy :artifacts, '   Resource::Artifact'
    proxy :repositories, 'Resource::Repository'
    proxy :users,        'Resource::User'
    proxy :system,       'Resource::System'

    #
    # Create a new Artifactory Client with the given options. Any options
    # given take precedence over the default options.
    #
    # @return [Artifactory::Client]
    #
    def initialize(options = {})
      # Use any options given, but fall back to the defaults set on the module
      Artifactory::Configurable.keys.each do |key|
        value = if options[key].nil?
          Artifactory.instance_variable_get(:"@#{key}")
        else
          options[key]
        end

        instance_variable_set(:"@#{key}", value)
      end
    end

    #
    # Determine if the given options are the same as ours.
    #
    # @return [Boolean]
    #
    def same_options?(opts)
      opts.hash == options.hash
    end

    #
    # Make a HTTP GET request
    #
    # @param [String] path
    #   the path to get, relative to {Defaults.endpoint}
    #
    def get(path, *args, &block)
      request(:get, path, *args, &block)
    end

    #
    # Make a HTTP POST request
    #
    # @param [String] path
    #   the path to post, relative to {Defaults.endpoint}
    #
    def post(path, *args, &block)
      request(:post, path, *args, &block)
    end

    #
    # Make a HTTP PUT request
    #
    # @param [String] path
    #   the path to put, relative to {Defaults.endpoint}
    #
    def put(path, *args, &block)
      request(:put, path, *args, &block)
    end

    #
    # Make a HTTP PATCH request
    #
    # @param [String] path
    #   the path to patch, relative to {Defaults.endpoint}
    #
    def patch(path, *args, &block)
      request(:patch, path, *args, &block)
    end

    #
    # Make a HTTP DELETE request
    #
    # @param [String] path
    #   the path to delete, relative to {Defaults.endpoint}
    #
    def delete(path, *args, &block)
      request(:delete, path, *args, &block)
    end

    #
    # Make a HTTP HEAD request
    #
    # @param [String] path
    #   the path to head, relative to {Defaults.endpoint}
    #
    def head(path, *args, &block)
      request(:head, path, *args, &block)
    end

    #
    # The actually HTTPClient agent.
    #
    # @return [HTTPClient]
    #
    def agent
      @agent ||= begin
        agent = HTTPClient.new(endpoint)

        agent.agent_name = user_agent

        # Check if authentication was given
        if username && password
          agent.set_auth(endpoint, username, password)

          # https://github.com/nahi/httpclient/issues/63#issuecomment-2377919
          agent.www_auth.basic_auth.challenge(endpoint)
        end

        # Check if proxy settings were given
        if proxy
          agent.proxy = proxy
        end

        agent
      end
    end

    #
    # Make an HTTP reequest with the given verb and path.
    #
    # @param [String, Symbol] verb
    #   the HTTP verb to use
    # @param [String] path
    #   the absolute or relative URL to use, expanded relative to {Defaults.endpoint}
    #
    # @return [Artifactory::RequestWrapper]
    #
    def request(verb, path, *args, &block)
      url = URI.parse(path)

      # Don't merge absolute URLs
      unless url.absolute?
        path = URI.parse(File.join(endpoint, path)).to_s
      end

      Request.new(verb, path) { agent.send(verb, path, *args, &block) }
    end
  end
end
