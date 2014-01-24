module Artifactory
  #
  # A re-usable class containing configuration information for the {Client}. See
  # {Defaults} for a list of default values.
  #
  module Configurable
    class << self
      #
      # The list of configurable keys.
      #
      # @return [Array<Symbol>]
      #
      def keys
        @keys ||= [
          :endpoint,
          :username,
          :password,
          :proxy,
          :user_agent,
        ]
      end
    end

    #
    # Create one attribute getter and setter for each key.
    #
    Artifactory::Configurable.keys.each do |key|
      attr_accessor key
    end

    #
    # Set the configuration for this config, using a block.
    #
    # @example Configure the API endpoint
    #   Artifactory.configure do |config|
    #     config.endpoint = "http://www.my-artifactory-server.com/artifactory"
    #   end
    #
    def configure
      yield self
    end

    #
    # Reset all configuration options to their default values.
    #
    # @example Reset all settings
    #   Artifactory.reset!
    #
    # @return [self]
    #
    def reset!
      Artifactory::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Defaults.options[key])
      end
      self
    end
    alias_method :setup, :reset!

    private

    #
    # The list of configurable keys, as an options hash.
    #
    # @return [Hash]
    #
    def options
      map = Artifactory::Configurable.keys.map do |key|
        [key, instance_variable_get(:"@#{key}")]
      end
      Hash[map]
    end
  end
end
