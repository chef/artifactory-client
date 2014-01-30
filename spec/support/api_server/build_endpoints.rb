module Artifactory
  module APIServer::BuildEndpoints
    def self.registered(app)
      app.get('/api/build') do
        content_type 'application/vnd.org.jfrog.build.Builds+json'
        JSON.fast_generate(
          'uri'    => server_url.join('/api/build'),
          'builds' => [
            {
              'uri'         => '/wicket',
              'lastStarted' => '2014-01-01 12:00:00',
            },
            {
              'uri'         => '/jackrabbit',
              'lastStarted' => '2014-02-11 10:00:00',
            }
          ]
        )
      end
    end
  end
end
