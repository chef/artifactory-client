module Artifactory
  class Resource::System < Resource::Base
    def self.info
      _get('/api/system').body
    end

    def self.ping
      _get('/api/system/ping').ok?
    rescue Error::ConnectionError
      false
    end

    def self.configuration
      _get('/api/system/configuration').xml
    end

    def self.update_configuration(xml)
      _post('/api/system/configuration', xml)
    end

    def self.version
      _get('/api/system/version').json
    end
  end
end
