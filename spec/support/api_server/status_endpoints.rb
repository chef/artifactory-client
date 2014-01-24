module Artifactory
  module APIServer::StatusEndpoints
    def self.registered(app)
      app.get('/status/:code') { code.to_i }
      app.post('/status/:code') { code.to_i }
      app.patch('/status/:code') { code.to_i }
      app.put('/status/:code') { code.to_i }
      app.delete('/status/:code') { code.to_i }
    end
  end
end
