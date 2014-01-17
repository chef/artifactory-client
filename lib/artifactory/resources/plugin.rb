module Artifactory
  class Resource::Plugin < Resource::Base
    def self.all
      get('/api/plugins').json
    end
  end
end
