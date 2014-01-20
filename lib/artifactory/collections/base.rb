module Artifactory
  class Collection::Base
    #
    # Create a new collection object (proxy).
    #
    # @param [Class] klass
    #   the child class object
    # @param [Object] parent
    #   the parent object who created the collection
    # @param [Hash] options
    #   the list of options given by the parent
    # @param [Proc] block
    #   the block to evaluate for the instance
    #
    def initialize(klass, parent, options = {}, &block)
      @klass   = klass
      @parent  = parent
      @options = options
      @block   = block
    end

    #
    # Use method missing to delegate methods to the class object or instance
    # object.
    #
    def method_missing(m, *args, &block)
      if klass.respond_to?(m)
        if args.last.is_a?(Hash)
          args.last.merge(options)
        end

        klass.send(m, *args, &block)
      else
        instance.send(m, *args, &block)
      end
    end

    private

    attr_reader :klass
    attr_reader :parent
    attr_reader :options
    attr_reader :block

    def instance
      @instance ||= parent.instance_eval(&block)
    end
  end
end
