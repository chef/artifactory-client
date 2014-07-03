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
        from_hash(flat_hash(response), client: client)
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
        from_hash(flat_hash(client.get(url)), client: client)
      end

      #
      # Flatten a hash
      #
      def flat_hash(deep_hash)
        fh = {}
        deep_hash.each do |key, value|
          if value.is_a?(Hash)
            value.each do |k, v|
              fh[k] = v
            end
          else
            fh[key] = value
          end
        end
        fh
      end
    end

    attribute :name, ->{ raise 'Name missing!' }
    attribute :include_pattern
    attribute :excludes_pattern
    attribute :repositories
    attribute :users
    attribute :groups

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
      client.put(api_path, to_json, headers)
      true
    end

    def to_hash
      principals = {}
      attributes.inject({}) do |hash, (key, value)|
        if key.eql?(:users) || key.eql?(:groups)
          principals[key.to_s] = value
          hash['principals'] = principals
        end
        unless Resource::Base.has_attribute?(key) || key.eql?(:users) || key.eql?(:groups)
          hash[Util.camelize(key, true)] = value
        end

        hash
      end
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
