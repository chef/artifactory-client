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
      # @return [Array<Resource<Layout>]
      #   the list of layouts
      #
      def all(options = {})
        config = Resource::System.configuration(options)
        list_from_config("config/repoLayouts/repoLayout", config, options)
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

      def list_from_config(xpath, config, options = {})
        all = Array.new
        REXML::XPath.match(config, xpath).map do |r|
          hash = Hash.new
          r.each_element_with_text do |l|
            hash[l.name] = l.get_text
          end
          thing = from_hash(hash, options)
          all.push(thing)
        end
        return all
      end

      def find_from_config(xpath, config, options = {})
        name_node = REXML::XPath.match(config, xpath)
        properties = Hash.new
        name_node[0].parent.each_element_with_text do |e|
          properties[e.name] = e.text
        end

        from_hash(properties, options)
      end
    end

    attribute :name
    attribute :artifact_path_pattern
    attribute :distinctive_descriptor_path_pattern
    attribute :descriptor_path_pattern
    attribute :folder_integration_revision_reg_exp
    attribute :file_integration_revision_reg_exp
  end
end
