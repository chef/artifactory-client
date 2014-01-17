module Artifactory
  module Error
    class ArtifactoryError < StandardError
      def initialize(options = {})
        class_name = self.class.to_s.split('::').last
        error_key  = Util.underscore(class_name)

        super I18n.t("artifactory.errors.#{error_key}", options)
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
