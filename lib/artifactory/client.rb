require 'json'
require 'net/http'
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
    #
    #
    def request(verb, path, params = {}, headers = {})
      # Build the URI and request object from the given information
      uri = build_uri(verb, path, params)
      request = class_for_request(verb).new(uri.request_uri)

      # Add headers
      default_headers.merge(headers).each do |key, value|
        request.add_field(key, value)
      end

      # Add basic authentication
      if username && password
        request.basic_auth(username, password)
      end

      # Setup PATCH/POST/PUT
      if [:patch, :post, :put].include?(verb)
        if params.is_a?(Hash)
          request.form_data = params
        else
          request.body = params
        end
      end

      # Create the HTTP connection object - since the proxy information defaults
      # to +nil+, we can just pass it to the initializer method instead of doing
      # crazy strange conditionals.
      connection = Net::HTTP.new(uri.host, uri.port,
        proxy_address, proxy_port, proxy_username, proxy_password)

      # Apply SSL, if applicable
      if uri.scheme == 'https'
        require 'net/https' unless defined?(Net::HTTPS)

        # Turn on SSL
        connection.use_ssl = true

        # Custom pem files, no problem!
        if ssl_pem_file
          pem = File.read(ssl_pem_file)
          connection.cert = OpenSSL::X509::Certificate.new(pem)
          connection.key = OpenSSL::PKey::RSA.new(pem)
          connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end

        # Naughty, naughty, naughty! Don't blame when when someone hops in
        # and executes a MITM attack!
        unless ssl_verify
          connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end

      # Create a connection using the block form, which will ensure the socket
      # is properly closed in the event of an error.
      connection.start do |http|
        response = http.request(request)

        case response
        when Net::HTTPRedirection
          redirect = URI.parse(response['location'])
          request(verb, redirect, params, headers)
        when Net::HTTPSuccess
          success(response)
        else
          error(response)
        end
      end
    rescue SocketError, Errno::ECONNREFUSED, EOFError
      raise Error::ConnectionError.new(endpoint)
    end

    #
    # The list of default headers (such as Keep-Alive and User-Agent) for the
    # client object.
    #
    # @return [Hash]
    #
    def default_headers
      {
        'Connection' => 'keep-alive',
        'Keep-Alive' => '30',
        'User-Agent' => user_agent,
      }
    end

    #
    # Construct a URL from the given verb and path. If the request is a GET or
    # DELETE request, the params are assumed to be query params are are
    # converted as such using {to_query_string}.
    #
    # If the path is relative, it is merged with the {endpoint} attribute. If
    # the path is absolute, it is converted to a URI object and returned.
    #
    # @param [Symbol] verb
    #   the lowercase HTTP verb (e.g. :+get+)
    # @param [String] path
    #   the absolute or relative HTTP path (url) to get
    # @param [Hash] params
    #   the list of params to build the URI with (for GET and DELETE requests)
    #
    # @return [URI]
    #
    def build_uri(verb, path, params = {})
      # Add any query string parameters
      if [:delete, :get].include?(verb)
        path = [path, to_query_string(params)].compact.join('?')
      end

      # Parse the URI
      uri = URI.parse(path)

      # Don't merge absolute URLs
      uri = URI.parse(File.join(endpoint, path)) unless uri.absolute?

      # Return the URI object
      uri
    end

    #
    # Helper method to get the corresponding {Net::HTTP} class from the given
    # HTTP verb.
    #
    # @param [#to_s] verb
    #   the HTTP verb to create a class from
    #
    # @return [Class]
    #
    def class_for_request(verb)
      Net::HTTP.const_get(verb.to_s.capitalize)
    end

    #
    # Convert the given hash to a list of query string parameters. Each key and
    # value in the hash is URI-escaped for safety.
    #
    # @param [Hash] hash
    #   the hash to create the query string from
    #
    # @return [String, nil]
    #   the query string as a string, or +nil+ if there are no params
    #
    def to_query_string(hash)
      hash.map do |key, value|
        "#{URI.escape(key.to_s)}=#{URI.escape(value.to_s)}"
      end.join('&')[/.+/]
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
    def success(response)
      if (response.content_type || '').include?('json')
        JSON.parse(response.body)
      else
        response.body
      end
    end

    #
    # Raise a response error, extracting as much information from the server's
    # response as possible.
    #
    # @raise [Error::HTTPError]
    #
    # @param [HTTP::Message] response
    #   the response object from the request
    #
    def error(response)
      error = JSON.parse(response.body)['errors'].first
      raise Error::HTTPError.new(error)
    rescue JSON::ParserError
      raise Error::HTTPError.new(
        'status'  => response.code,
        'message' => response.body,
      )
    end
  end
end
