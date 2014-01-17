module Artifactory
  class Resource::Base
    #
    # Dynamically define shortcut delegators to the connection object.
    #
    Connection::HTTP_VERBS.each do |verb|
      define_singleton_method(verb) do |*args|
        Artifactory.connection.send(verb, *args)
      end

      define_method(verb) do |*args|
        self.class.send(verb, *args)
      end
    end

    class << self
      #
      # @macro attribute
      #   @method $1
      #     Return this object's $1
      #
      #
      #   @method $1=(value)
      #     Set this objects $1
      #
      #     @param [Object] value
      #       the value to set for $1
      #
      def attribute(key)
        define_method(key) do
          instance_variable_get("@#{key}")
        end

        define_method("#{key}=") do |value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
