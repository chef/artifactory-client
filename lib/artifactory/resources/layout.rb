require 'rexml/document'

module Artifactory
  class Resource::Layout < Resource::Base
    class << self
      #
      # Get a list of all repository layouts in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::Layout>]
      #   the list of layouts
      #
      def all(options = {})
        config = Resource::System.configuration(options)
        list_from_config('config/repoLayouts/repoLayout', config, options)
      end

      #
      # Find (fetch) a layout by its name.
      #
      # @example Find a layout by its name
      #   Layout.find('maven-2-default') #=> #<Layout name: 'maven-2-default' ...>
      #
      # @param [String] name
      #   the name of the layout to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::Layout, nil]
      #   an instance of the layout that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        config = Resource::System.configuration(options)
        find_from_config("config/repoLayouts/repoLayout/name[text()='#{name}']", config, options)
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
          properties[e.name] = to_type(e.text)
        end

        from_hash(properties, options)
      end

      def to_type(string)
        return true if string.eql?('true')
        return false if string.eql?('false')
        return string.to_i if numeric?(string)
        return string
      end

      def numeric?(string)
        string.to_i.to_s == string || string.to_f.to_s == string
      end
    end

    attribute :name, ->{ raise 'Name missing!' }
    attribute :artifact_path_pattern
    attribute :distinctive_descriptor_path_pattern, true
    attribute :descriptor_path_pattern
    attribute :folder_integration_revision_reg_exp
    attribute :file_integration_revision_reg_exp
  end
end
