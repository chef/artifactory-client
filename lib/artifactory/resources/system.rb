module Artifactory
  class Resource::System < Resource::Base
    def self.info
      get('/api/system').body
    end

    def self.ping
      get('/api/system/ping').ok?
    rescue Error::ConnectionError
      false
    end

    def self.configuration
      get('/api/system/configuration').xml
    end

    def self.update_configuration(xml)
      post('/api/system/configuration', xml)
    end

    def self.version
      get('/api/system/version').json
    end
  end
end
