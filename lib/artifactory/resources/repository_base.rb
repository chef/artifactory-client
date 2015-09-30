module Artifactory
  module Resource::RepositoryBase

    def self.included(clazz)
      clazz.attribute :key, ->{ raise 'Key is missing!' }

      class << clazz
        #
        # Get a list of all repositories in the system.
        #
        # @param [Hash] options
        #   the list of options
        #
        # @option options [Artifactory::Client] :client
        #   the client object to make the request with
        #
        # @return [Array<Resource::Repository>]
        #   the list of builds
        #
        def all(options = {})
          client = extract_client!(options)
          client.get('/api/repositories').map do |hash|
            find(hash['key'], client: client)
          end.compact
        end

        #
        # Find (fetch) a repository by name.
        #
        # @example Find a repository by named key
        #   Repository.find(name: 'libs-release-local') #=> #<Resource::Artifact>
        #
        # @param [Hash] options
        #   the list of options
        #
        # @option options [String] :name
        #   the name of the repository to find
        # @option options [Artifactory::Client] :client
        #   the client object to make the request with
        #
        # @return [Resource::Repository, nil]
        #   an instance of the repository that matches the given name, or +nil+
        #   if one does not exist
        #
        def find(name, options = {})
          client = extract_client!(options)

          response = client.get("/api/repositories/#{url_safe(name)}")
          from_hash(response, client: client)
        rescue Error::HTTPError => e
          raise unless e.code == 400
          nil
        end
      end
    end
    #
    # Creates or updates a repository configuration depending on if the
    # repository configuration previously existed. This method also works
    # around Artifactory's dangerous default behavior:
    #
    #   > An existing repository with the same key are removed from the
    #   > configuration and its content is removed!
    #
    # @return [Boolean]
    #
    def save
      if self.class.find(key, client: client)
        client.post(api_path, to_json, headers)
      else
        client.put(api_path, to_json, headers)
      end
      true
    end

    #
    # Delete this repository from artifactory, suppressing any +ResourceNotFound+
    # exceptions might occur.
    #
    # @return [Boolean]
    #   true if the object was deleted successfully, false otherwise
    #
    def delete
      client.delete(api_path)
      true
    rescue Error::HTTPError => e
      false
    end

    private

    #
    # The path to this repository on the server.
    #
    # @return [String]
    #
    def api_path
      "/api/repositories/#{url_safe(key)}"
    end

    #
    # The default headers for this object. This includes the +Content-Type+.
    #
    # @return [Hash]
    #
    def headers
      @headers ||= {
        'Content-Type' => content_type
      }
    end
  end
end