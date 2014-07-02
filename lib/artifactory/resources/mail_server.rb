require 'rexml/document'

module Artifactory
  class Resource::MailServer < Resource::Base
    class << self
      #
      # Get a list of all mail servers in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::MailServer>]
      #   the list of layouts
      #
      def all(options = {})
        config = Resource::System.configuration(options)
        list_from_config('config/mailServer', config, options)
      end

      #
      # Find (fetch) a mail server by its host.
      #
      # @example Find a MailServer by its host.
      #   mail_server.find('smtp.gmail.com') #=> #<MailServer host: 'smtp.gmail.com' ...>
      #
      # @param [String] host
      #   the host of the mail server to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::MailServer, nil]
      #   an instance of the mail server that matches the given host, or +nil+
      #   if one does not exist
      #
      def find(host, options = {})
        config = Resource::System.configuration(options)
        find_from_config("config/mailServer/host[text()='#{host}']", config, options)
      rescue Error::HTTPError => e
        raise unless e.code == 404
        nil
      end
    end

    attribute :enabled
    attribute :host, ->{ raise 'host missing!' }
    attribute :port
    attribute :username
    attribute :password
    attribute :from
    attribute :subject_prefix
    attribute :tls
    attribute :ssl
    attribute :artifactory_url
  end
end
