module Artifactory
  class Resource::User < Resource::Base
    class << self
      #
      #
      #
      def all(client)
        client.get('/api/security/users').json.map do |hash|
          from_url(client, hash['uri'])
        end
      end

      #
      #
      #
      def find(client, username)
        username = URI.escape(username)
        from_hash(client, client.get("/api/security/users/#{username}").json)
      rescue Error::NotFound
        nil
      end

      #
      #
      #
      def from_url(client, url)
        from_hash(client, client.get(url).json)
      end

      #
      #
      #
      def from_hash(client, hash)
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

    #
    # Create a new user object.
    #
    def initialize(client, attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end
