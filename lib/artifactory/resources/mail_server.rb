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

      private
      #
      # List all the child text elements in the Artifactory configuration file
      # of a node matching the specified xpath
      #
      # @param [String] xpath
      #   xpath expression for the parent element whose children are to be listed
      #
      # @param [REXML] config
      #   Artifactory config as an REXML file
      #
      # @param [Hash] options
      #   the list of options
      #
      def list_from_config(xpath, config, options = {})
        REXML::XPath.match(config, xpath).map do |r|
          hash = {}

          r.each_element_with_text do |l|
            hash[l.name] = l.get_text
          end
          from_hash(hash, options)
        end
      end

      #
      # Find all the sibling text elements in the Artifactory configuration file
      # of a node matching the specified xpath
      #
      # @param [String] xpath
      #   xpath expression for the element whose siblings are to be found
      #
      # @param [REXML] config
      #   Artifactory configuration file as an REXML doc
      #
      # @param [Hash] options
      #   the list of options
      #
      def find_from_config(xpath, config, options = {})
        name_node = REXML::XPath.match(config, xpath)
        return nil if name_node.empty?
        properties = {}
        name_node[0].parent.each_element_with_text do |e|
          properties[e.name] = e.text
        end

        from_hash(properties, options)
      end
    end

    attribute :enabled, 'true'
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
