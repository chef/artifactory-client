module Artifactory
  class Resource::Build < Resource::Base
    class << self
      #
      # Search for all builds in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::Build>]
      #   the list of builds
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/build').json
      rescue Error::NotFound
        # Artifactory returns a 404 instead of an empty list when there are no
        # builds. Whoever decided that was a good idea clearly doesn't
        # understand the point of REST interfaces...
        []
      end
    end
  end
end
