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
      def proxy(klass)
        namespace = klass.name.split('::').last.downcase
        klass.singleton_methods(false).each do |name|
          define_method("#{namespace}_#{name}") do |*args|
            if args.last.is_a?(Hash)
              args.last[:client] = self
            else
              args << { client: self }
            end

            klass.send(name, *args)
          end
        end
      end
    end

    include Artifactory::Configurable

    proxy Resource::Artifact
    proxy Resource::Repository
    proxy Resource::User
    proxy Resource::System

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
    # @return [Object]
    #
    def request(verb, path, *args, &block)
      url = URI.parse(path)

      # Don't merge absolute URLs
      unless url.absolute?
        url = URI.parse(File.join(endpoint, path)).to_s
      end

      # Covert the URL back into a string
      url = url.to_s

      # Make the actual request
      response = agent.send(verb, url, *args, &block)

      case response.status.to_i
      when 200..399
        parse_response(response)
      when 400
        raise Error::BadRequest.new(url: url, body: response.body)
      when 401
        raise Error::Unauthorized.new(url: url)
      when 403
        raise Error::Forbidden.new(url: url)
      when 404
        raise Error::NotFound.new(url: url)
      when 405
        raise Error::MethodNotAllowed.new(url: url)
      else
        raise Error::ConnectionError.new(url: url, body: response.body)
      end
    rescue SocketError, Errno::ECONNREFUSED, EOFError
      raise Error::ConnectionError.new(url: url, body: <<-EOH.gsub(/^ {8}/, ''))
        The server is not currently accepting connections.
      EOH
    end


    #
    # Parse the response object and manipulate the result based on the given
    # +Content-Type+ header. For now, this method only parses JSON, but it
    # could be expanded in the future to accept other content types.
    #
    # @param [HTTP::Message] response
    #   the response object from the request
    #
    # @return [String, Hash]
    #   the parsed response, as an object
    #
    def parse_response(response)
      content_type = response.headers['Content-Type']

      if content_type && content_type.include?('json')
        JSON.parse(response.body)
      else
        response.body
      end
    end
  end
end
