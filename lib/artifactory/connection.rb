require 'httpclient'
require 'json'
require 'rexml/document'
require 'uri'

module Artifactory
  class Connection
    HTTP_VERBS = %w[delete get head post put].freeze

    attr_reader :options

    def initialize(options = {})
      @options = {
        url:             nil,
        send_timeout:    6000,
        receive_timeout: 6000,
        auth:            nil,
        proxy:           nil,
      }.merge(options)
    end

    HTTP_VERBS.each do |verb|
      define_method(verb) do |*args, &block|
        path = args.shift

        # Don't merge absolute URLs
        if path =~ /https?\:\/\//
          full_url = URI.parse(path).normalize.to_s
          args.unshift(path)
        else
          full_url = URI.parse(File.join(options[:url], path)).normalize.to_s
          args.unshift(full_url)
        end

        ResponseWrapper.new(full_url, verb) do
          client.send(verb, *args, &block)
        end
      end
    end

    def to_s
      "#<#{self.class} url: #{options[:url].inspect}>"
    end

    def inspect
      "#<#{self.class} url: #{options[:url].inspect}, client: #{client.inspect}>"
    end

    private

    def client
      @client ||= begin
        client = HTTPClient.new(options[:url])

        if auth = options[:auth]
          client.set_auth(options[:url], auth[:username], auth[:password])

          # https://github.com/nahi/httpclient/issues/63#issuecomment-2377919
          client.www_auth.basic_auth.challenge(options[:url])
        end

        if proxy = options[:proxy]
          client.set_proxy_auth(proxy[:username], proxy[:password])
        end

        client
      end
    end
  end

  class ResponseWrapper
    attr_reader :method
    attr_reader :url

    def initialize(url, method, &request)
      @url     = url
      @method  = method.to_s.upcase
      @request = request
    end

    def body
      response.body
    end

    def code
      response.code.to_i
    end

    #
    # Determines if a response is "OK". A response is OK if it returned a 200
    # or 300 status.
    #
    # @return [Boolean]
    #   true if the response is OK, false otherwise
    #
    def ok?
      code.between?(200, 399)
    end
    alias_method :success?, :ok?

    def json
      @json ||= JSON.parse(body)
    end

    def xml
      @xml ||= REXML::Document.new(body)
    end

    def to_s
      "#<#{self.class} #{method} #{url}>"
    end

    def inspect
      "#<#{self.class} #{method} #{url} (#{code})>"
    end

    private

    def response
      return @response if @response

      @response = @request.call

      case @response.status.to_i
      when 400
        raise Error::BadRequest.new(url: url, body: @response.body)
      when 401
        raise Error::Unauthorized.new(url: url)
      when 403
        raise Error::Forbidden.new(url: url)
      when 404
        raise Error::NotFound.new(url: url)
      when 405
        raise Error::MethodNotAllowed.new(url: url)
      when 500..600
        raise Error::ConnectionError.new(url: url, body: @response.body)
      end

      @response
    rescue SocketError, Errno::ECONNREFUSED, EOFError
      raise Error::ConnectionError.new(url: url, body: <<-EOH.gsub(/^ {8}/, ''))
        The server is not currently accepting connections.
      EOH
    end
  end
end
