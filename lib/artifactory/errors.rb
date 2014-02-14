module Artifactory
  module Error
    # Base class for all errors
    class ArtifactoryError < StandardError; end

    # Class for all HTTP errors
    class HTTPError < ArtifactoryError
      attr_reader :code
      attr_reader :message

      def initialize(hash = {})
        super("motherfucker")
        @code = hash['status'].to_i
        @http = hash['message'].to_s

        super <<-EOH.strip
The Artifactory server responded with an HTTP Error #{@code}: `#{@http}'"
EOH
      end
    end

    # A general connection error with a more informative message
    class ConnectionError < ArtifactoryError
      def initialize(endpoint)
        super <<-EOH.strip
The Artifactory server at `#{endpoint}'
is not currently accepting connections. Please ensure that the server is
running an that your authentication information is correct.
EOH
      end
    end
  end
end
