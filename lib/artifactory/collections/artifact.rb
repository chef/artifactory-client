module Artifactory
  class Collection::Artifact < Collection::Base
    #
    # Create a new artifact collection.
    #
    # @param (see Collection::Base#initialize)
    #
    def initialize(parent, options = {}, &block)
      super(Resource::Artifact, parent, options, &block)
    end
  end
end
