require 'rexml/document'

module Artifactory
  class Resource::UrlBase < Resource::Base
    class << self
      #
      # List UrlBase in the system configuration.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::UrlBase>]
      #   the list of UrlBases
      #
      def all(options = {})
        config = Resource::System.configuration(options)
        simple_text_from_config('config/urlBase', config, options)
      end

      #
      # Find (fetch) the url base.
      #
      # @example Find a UrlBase by its url_base.
      #   url_base.find('http://33.33.33.20/artifactory') #=> #<UrlBase url_base: 'http://33.33.33.20/artifactory' ...>
      #
      # @param [String] url
      #   the base url to find
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
      def find(url, options = {})
        config = Resource::System.configuration(options)
        find_from_config("config/urlBase[text()='#{url}']", config, options)
      rescue Error::HTTPError => e
        raise unless e.code == 404
        nil
      end

      private
      #
      # List all the text elements in the Artifactory configuration file
      # matching the given xpath.  Ignore any children of elements that match the xpath.
      #
      # @param [String] xpath
      #   xpath expression for which matches are to be listed
      #
      # @param [REXML] config
      #   Artifactory config as an REXML file
      #
      # @param [Hash] options
      #   the list of options
      #
      def simple_text_from_config(xpath, config, options = {})
        REXML::XPath.match(config, xpath).map do |r|
          hash = {}
          hash[r.name] = r.text
          from_hash(hash, options)
        end
      end

      #
      # Find the text elements matching a giving xpath
      #
      # @param [String] xpath
      #   xpath expression
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

    attribute :url_base, ->{ raise 'URL base missing!' }
  end
end
