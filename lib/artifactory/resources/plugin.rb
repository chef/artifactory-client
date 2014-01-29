module Artifactory
  class Resource::Plugin < Resource::Base
    class << self
      #
      # Get a list of all plugins in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::Plugin>]
      #   the list of builds
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/plugins')
      end
    end
  end
end
