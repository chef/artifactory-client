module Artifactory
  class Resource::Group < Resource::Base
    class << self
      #
      # Get a list of all groups in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::Group>]
      #   the list of groups
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/security/groups').map do |hash|
          from_url(hash['uri'], client: client)
        end
      end

      #
      # Find (fetch) a group by its name.
      #
      # @example Find a group by its name
      #   Group.find('readers') #=> #<Group name: 'readers' ...>
      #
      # @param [String] name
      #   the name of the group to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::Group, nil]
      #   an instance of the group that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        client = extract_client!(options)

        response = client.get("/api/security/groups/#{url_safe(name)}")
        from_hash(response, client: client)
      rescue Error::NotFound
        nil
      end

      #
      # Construct a group from the given URL.
      #
      # @example Create an group object from the given URL
      #   Group.from_url('/security/groups/readers') #=> #<Resource::Group>
      #
      # @param [Artifactory::Client] client
      #   the client object to make the request with
      # @param [String] url
      #   the URL to find the group from
      #
      # @return [Resource::Group]
      #
      def from_url(url, options = {})
        client = extract_client!(options)
        from_hash(client.get(url), client: client)
      end

      #
      # Create a instance from the given Hash. This method extracts the "safe"
      # information from the hash and adds them to the instance.
      #
      # @example Create a new group from a hash
      #   Group.from_hash('realmAttributes' => '...', 'name' => '...')
      #
      # @param [Artifactory::Client] client
      #   the client object to make the request with
      # @param [Hash] hash
      #   the hash to create the instance from
      #
      # @return [Resource::Group]
      #
      def from_hash(hash, options = {})
        client = extract_client!(options)

        new.tap do |instance|
          instance.auto_join        = hash['autoJoin']
          instance.client           = client
          instance.description      = hash['description']
          instance.name             = hash['name']
          instance.realm            = hash['realm']
          instance.realm_attributes = hash['realmAttributes']
        end
      end
    end

    attribute :auto_join
    attribute :description
    attribute :name, ->{ raise 'Name missing!' }
    attribute :realm
    attribute :realm_attributes

    #
    # Delete this group from artifactory, suppressing any +ResourceNotFound+
    # exceptions might occur.
    #
    # @return [Boolean]
    #   true if the object was deleted successfully, false otherwise
    #
    def delete
      !!client.delete(api_path)
    rescue Error::NotFound
      false
    end

    #
    # Save the group to the artifactory server.
    #
    # @return [Boolean]
    #
    def save
      client.put(api_path, to_json, headers)
      true
    end

    #
    # The hash format for this group.
    #
    # @return [Hash]
    #
    def to_hash
      {
        'autoJoin'        => auto_join,
        'description'     => description,
        'name'            => name,
        'realm'           => realm,
        'realmAttributes' => realm_attributes,
      }
    end

    #
    # The JSON representation of this resource.
    #
    # @return [String]
    #
    def to_json
      JSON.fast_generate(to_hash)
    end

    private

    #
    # The path to this group on the server.
    #
    # @return [String]
    #
    def api_path
      @api_path ||= "/api/security/groups/#{url_safe(name)}"
    end

    #
    # The default headers for this object. This includes the +Content-Type+.
    #
    # @return [Hash]
    #
    def headers
      @headers ||= {
        'Content-Type' => 'application/vnd.org.jfrog.artifactory.security.Group+json'
      }
    end
  end
end
