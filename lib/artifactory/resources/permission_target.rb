module Artifactory
  class Resource::PermissionTarget < Resource::Base
    class << self
      #
      # Get a list of all PermissionTargets in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::PermissionTarget>]
      #   the list of PermissionTargets
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/security/permissions').map do |hash|
          from_url(hash['uri'], client: client)
        end
      end

      #
      # Find (fetch) a permission target by its name.
      #
      # @example Find a permission target by its name
      #   PermissionTarget.find('readers') #=> #<PermissionTarget name: 'readers' ...>
      #
      # @param [String] name
      #   the name of the permission target to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::PermissionTarget, nil]
      #   an instance of the permission target that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        client = extract_client!(options)

        response = client.get("/api/security/permissions/#{url_safe(name)}")
        from_hash(response, client: client)
      rescue Error::HTTPError => e
        raise unless e.code == 404
        nil
      end

      #
      # @see Resource::Base.url_safe
      # Additionally flattens the hash returned from the client url
      #
      def from_url(url, options = {})
        client = extract_client!(options)
        from_hash(client.get(url), client: client)
      end
    end

    attribute :name, ->{ raise 'Name missing!' }
    attribute :includes_pattern, '**'
    attribute :excludes_pattern, ''
    attribute :repositories
    attribute :principals, { 'users' => {}, 'groups' => {} }

    #
    # Delete this PermissionTarget from artifactory, suppressing any +ResourceNotFound+
    # exceptions might occur.
    #
    # @return [Boolean]
    #   true if the object was deleted successfully, false otherwise
    #
    def delete
      client.delete(api_path)
        true
      rescue Error::HTTPError
        false
    end

    #
    # Save the PermissionTarget to the artifactory server.
    # See http://bit.ly/1qMOw0L
    #
    # @return [Boolean]
    #
    def save
      send("#{:principals}=", { 'users' => users, 'groups' => groups })
      client.put(api_path, to_json, headers)
      true
    end

    #
    # Getter for groups
    #
    def groups
      principals['groups']
    end

    #
    # Setter for groups
    #
    def groups=(groups_hash)
      principals['groups'] = groups_hash
    end

    #
    # Getter for users
    #
    def users
      principals['users']
    end

    #
    # Setter for users
    #
    def users=(users_hash)
      principals['users'] = users_hash
    end

    private

    #
    # The path to this PermissionTarget on the server.
    #
    # @return [String]
    #
    def api_path
      @api_path ||= "/api/security/permissions/#{url_safe(name)}"
    end

    #
    # The default headers for this object. This includes the +Content-Type+.
    #
    # @return [Hash]
    #
    def headers
      @headers ||= {
        'Content-Type' => 'application/vnd.org.jfrog.artifactory.security.PermissionTarget+json'
      }
    end
  end
end
