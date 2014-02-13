module Artifactory
  class Resource::User < Resource::Base
    class << self
      #
      # Get a list of all users in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::User>]
      #   the list of users
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/security/users').map do |hash|
          from_url(hash['uri'], client: client)
        end
      end

      #
      # Find (fetch) a user by its name.
      #
      # @example Find a user by its name
      #   User.find('readers') #=> #<User name: 'readers' ...>
      #
      # @param [String] name
      #   the name of the user to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::User, nil]
      #   an instance of the user that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        client = extract_client!(options)

        response = client.get("/api/security/users/#{url_safe(name)}")
        from_hash(response, client: client)
      rescue Error::NotFound
        nil
      end
    end

    attribute :admin, false
    attribute :email
    attribute :groups, []
    attribute :internal_password_disabled, false
    attribute :last_logged_in
    attribute :name, -> { raise 'Name missing' }
    attribute :password # write only, never returned
    attribute :profile_updatable, true
    attribute :realm

    #
    # Delete this user from artifactory, suppressing any +ResourceNotFound+
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
    # Save the user to the artifactory server.
    #
    # @return [Boolean]
    #
    def save
      client.put(api_path, to_json, headers)
      true
    end

    private

    #
    # The path to this user on the server.
    #
    # @return [String]
    #
    def api_path
      @api_path ||= "/api/security/users/#{url_safe(name)}"
    end

    #
    # The default headers for this object. This includes the +Content-Type+.
    #
    # @return [Hash]
    #
    def headers
      @headers ||= {
        'Content-Type' => 'application/vnd.org.jfrog.artifactory.security.User+json'
      }
    end
  end
end
