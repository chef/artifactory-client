module Artifactory
  class Resource::Base
    #
    # Dynamically define shortcut delegators to the connection object. The
    # methods all begin with an underscore, to separate them from actual method
    # that might exist, like +delete+.
    #
    Connection::HTTP_VERBS.each do |verb|
      key = "_#{verb}".to_sym

      define_singleton_method(key) do |*args|
        Artifactory.connection.send(verb, *args)
      end

      define_method(key) do |*args|
        self.class.send(key, *args)
      end

      private key
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
      #     @param [Object] default
      #       the default value for this attribute
      #
      def attribute(key, default = nil)
        define_method(key) do
          value = instance_variable_get("@#{key}")
          return value unless value.nil?

          if default.nil?
            value
          elsif default.is_a?(Proc)
            default.call(self)
          else
            default
          end
        end

        define_method("#{key}=") do |value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
