module Artifactory
  class Resource::User < Resource::Base
    class << self
      #
      #
      #
      def all(options = {})
        client = extract_client!(options)
        client.get('/api/security/users').map do |hash|
          from_url(hash['uri'], client: client)
        end
      end

      #
      #
      #
      def find(options = {})
        client   = extract_client!(options)
        username = URI.escape(options[:username])
        response = client.get("/api/security/users/#{username}")
        from_hash(response, client: client)
      rescue Error::NotFound
        nil
      end

      #
      #
      #
      def from_url(url, options = {})
        client = extract_client!(options)
        from_hash(client.get(url), client: client)
      end

      #
      #
      #
      def from_hash(hash, options = {})
        client = extract_client!(options)

        new(client).tap do |instance|
          instance.admin      = hash['admin']
          instance.email      = hash['email']
          instance.last_login = Time.parse(hash['lastLoggedIn']) rescue nil
          instance.name       = hash['name']
          instance.realm      = hash['realm']
        end
      end
    end

    attribute :admin, false
    attribute :email
    attribute :last_login
    attribute :name, ->{ raise 'Name missing!' }
    attribute :password
    attribute :realm
  end
end
