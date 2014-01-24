module Artifactory
  module APIServer::SystemEndpoints
    def self.registered(app)
      app.get('/api/system') do
        'This is some serious system info right here'
      end

      app.get('/api/system/ping') do
        'OK'
      end

      app.get('/api/system/configuration') do
        <<-EOH.gsub(/^ {10}/, '')
          <?xml version='1.0' encoding='UTF-8' standalone='yes'?>
          <config xsi:schemaLocation='http://www.jfrog.org/xsd/artifactory-v1_5_3.xsd'
                  xmlns='http://artifactory.jfrog.org/xsd/1.5.3'
                  xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
            <offlineMode>false</offlineMode>
          </config>
        EOH
      end

      app.post('/api/system/configuration') do
        # Just echo the response we got back, since it seems that's what a real
        # Artifactory server does...
        request.body.read
      end

      app.get('/api/system/version') do
        JSON.generate({
          'version' => '3.1.0',
          'revision' => '30062',
          'addons' => [
            'ldap',
            'license',
            'yum'
          ]
        })
      end
    end
  end
end
