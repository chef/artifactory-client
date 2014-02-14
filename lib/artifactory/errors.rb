module Artifactory
  module Error
    # Base class for all errors
    class ArtifactoryError < StandardError; end

      end
    end

    #
    # Client errors
    # ------------------------------
    class ConnectionError < ArtifactoryError; end
    class BadRequest < ConnectionError; end
    class Forbidden < ConnectionError; end
    class MethodNotAllowed < ConnectionError; end
    class NotFound < ConnectionError; end
    class Unauthorized < ConnectionError; end
  end
end
