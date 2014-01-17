module Artifactory
  class Resource::Build < Resource::Base
    def self.all
      get('/api/build').json
    rescue Error::NotFound
      # Artifactory returns a 404 instead of an empty list when there are no
      # builds. Whoever decided that was a good idea clearly doesn't understand
      # the point of REST interfaces...
      []
    end
  end
end
