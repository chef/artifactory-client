require 'artifactory/version'

module Artifactory
  module Defaults
    # Default API endpoint
    ENDPOINT = 'http://localhost:8080/artifactory'.freeze

    # Default User Agent header string
    USER_AGENT = "Artifactory Ruby Gem #{Artifactory::VERSION}".freeze

    class << self
      #
      # The list of calculated default options for the configuration.
      #
      # @return [Hash]
      #
      def options
        Hash[Configurable.keys.map { |key| [key, send(key)] }]
      end

      #
      # The endpoint where artifactory lives
      #
      # @return [String]
      #
      def endpoint
        ENV['ARTIFACTORY_ENDPOINT'] || ENDPOINT
      end

      #
      # The User Agent header to send along
      #
      # @return [String]
      #
      def user_agent
        ENV['ARTIFACTORY_USER_AGENT'] || USER_AGENT
      end

      #
      # The HTTP Basic Authentication username
      #
      # @return [String, nil]
      #
      def username
        ENV['ARTIFACTORY_USERNAME']
      end

      #
      # The HTTP Basic Authentication password
      #
      # @return [String, nil]
      #
      def password
        ENV['ARTIFACTORY_PASSWORD']
      end

      #
      # The HTTP Proxy information as a string
      #
      # @return [String, nil]
      #
      def proxy
        ENV['ARTIFACTORY_PROXY']
      end
    end
  end
end
