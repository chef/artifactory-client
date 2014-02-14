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
      rescue Error::HTTPError => e
        raise unless e.code == 404
        nil
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
      client.delete(api_path)
      true
    rescue Error::HTTPError
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
