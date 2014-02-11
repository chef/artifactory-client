require 'json'

module Artifactory
  class Resource::Base
    class << self
      #
      # @macro attribute
      #   @method $1
      #     Return this object's +$1+
      #
      #     @return [Object]
      #
      #
      #   @method $1=(value)
      #     Set this object's +$1+
      #
      #     @param [Object] value
      #       the value to set for +$1+
      #     @param [Object] default
      #       the default value for this attribute
      #
      #   @method $1?
      #     Determines if the +$1+ value exists and is truthy
      #
      #     @return [Boolean]
      #
      def attribute(key, default = nil)
        define_method(key) do
          value = instance_variable_get("@#{key}")
          return value unless value.nil?

          if default.nil?
            value
          elsif default.is_a?(Proc)
            default.call
          else
            default
          end
        end

        define_method("#{key}?") do
          !!send(key)
        end

        define_method("#{key}=") do |value|
          instance_variable_set("@#{key}", value)
        end
      end

      #
      # Get the client (connection) object from the given options. If the
      # +:client+ key is preset in the hash, it is assumed to contain the
      # connection object to use for the request. If the +:client+ key is not
      # present, the default {Artifactory.client} is used.
      #
      # Warning, the value of {Artifactory.client} is **not** threadsafe! If
      # multiple threads or processes are modifying the connection information,
      # the same request _could_ use a different client object. If you use the
      # {Artifactory::Client} proxy methods, this is handled for you.
      #
      # Warning, this method will **remove** the +:client+ key from the hash if
      # it exists.
      #
      # @param [Hash] options
      #   the list of options passed to the method
      #
      # @option options [Artifactory::Client] :client
      #   the client object to use for requests
      #
      def extract_client!(options)
        options.delete(:client) || Artifactory.client
      end

      #
      # Format the repos list from the given options. This method will modify
      # the given Hash parameter!
      #
      # Warning, this method will modify the given hash if it exists.
      #
      # @param [Hash] options
      #   the list of options to extract the repos from
      #
      def format_repos!(options)
        return options if options[:repos].nil? || options[:repos].empty?
        options[:repos] = Array(options[:repos]).compact.join(',')
        options
      end

      #
      # Generate a URL-safe string from the given value.
      #
      # @param [#to_s] value
      #   the value to sanitize
      #
      # @return [String]
      #   the URL-safe version of the string
      #
      def url_safe(value)
        URI.escape(value.to_s)
      end
    end

    attribute :client, ->{ Artifactory.client }

    #
    # Create a new instance
    #
    def initialize(attributes = {})
      attributes.each { |key, value| send(:"#{key}=", value) }
    end

    # @see {Resource::Base.extract_client!}
    def extract_client!(options)
      self.class.extract_client!(options)
    end

    # @see {Resource::Base.format_repos!}
    def format_repos!(options)
      self.class.format_repos!(options)
    end

    # @see {Resource::Base.url_safe}
    def url_safe(value)
      self.class.url_safe(value)
    end

    def to_s
      "#<#{self.class.name}>"
    end

    def inspect
      map = instance_variables.map do |k|
        unless k == :@client
          value = instance_variable_get(k)

          if !value.nil?
            "#{k.to_s.gsub(/^@/, '')}: #{value.inspect}"
          else
            nil
          end
        end
      end.compact

      "#<#{self.class.name} #{map.join(', ')}>"
    end
  end
end
