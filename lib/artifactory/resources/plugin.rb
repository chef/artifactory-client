module Artifactory
  class Resource::Plugin < Resource::Base
    def self.all
      _get('/api/plugins').json
    end
  end
end
