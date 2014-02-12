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

      #
      # Construct a user from the given URL.
      #
      # @example Create an user object from the given URL
      #   User.from_url('/security/users/readers') #=> #<Resource::User>
      #
      # @param [Artifactory::Client] client
      #   the client object to make the request with
      # @param [String] url
      #   the URL to find the user from
      #
      # @return [Resource::User]
      #
      def from_url(url, options = {})
        client = extract_client!(options)
        from_hash(client.get(url), client: client)
      end

      #
      # Create a instance from the given Hash. This method extracts the "safe"
      # information from the hash and adds them to the instance.
      #
      # @example Create a new user from a hash
      #   User.from_hash('realmAttributes' => '...', 'name' => '...')
      #
      # @param [Artifactory::Client] client
      #   the client object to make the request with
      # @param [Hash] hash
      #   the hash to create the instance from
      #
      # @return [Resource::User]
      #
      def from_hash(hash, options = {})
        client = extract_client!(options)

        new.tap do |instance|
          instance.admin                      = !!hash['admin']
          instance.email                      = hash['email']
          instance.groups                     = Array(hash['groups'])
          instance.internal_password_disabled = hash['internalPasswordDisabled']
          instance.last_logged_in             = hash['lastLoggedIn']
          instance.name                       = hash['name']
          instance.password                   = hash['password']
          instance.profile_updatable          = !!hash['profileUpdatable']
          instance.realm                      = hash['realm']
        end
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

    #
    # The hash format for this user.
    #
    # @return [Hash]
    #
    def to_hash
      {
        'admin'                    => admin,
        'email'                    => email,
        'groups'                   => groups,
        'internalPasswordDisabled' => internal_password_disabled,
        'lastLoggedIn'             => last_logged_in,
        'name'                     => name,
        'password'                 => password,
        'profileUpdatable'         => profile_updatable,
        'realm'                    => realm,
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
