module Artifactory
  module Error
    # Base class for all errors
    class ArtifactoryError < StandardError; end

    # Class for all HTTP errors
    class HTTPError < ArtifactoryError
      attr_reader :code

      def initialize(hash = {})
        @code = hash['status'].to_i
        @http = hash['message'].to_s

        super "The Artifactory server responded with an HTTP Error " \
              "#{@code}: `#{@http}'"
      end
    end

    # A general connection error with a more informative message
    class ConnectionError < ArtifactoryError
      def initialize(endpoint)
        super "The Artifactory server at `#{endpoint}' is not currently " \
              "accepting connections. Please ensure that the server is " \
              "running an that your authentication information is correct."
      end
    end
  end
end
