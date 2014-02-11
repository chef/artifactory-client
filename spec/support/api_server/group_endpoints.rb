module Artifactory
  module APIServer::GroupEndpoints
    def self.registered(app)
      app.get('/api/security/groups') do
        content_type 'application/vnd.org.jfrog.artifactory.security.Groups+json'
        JSON.fast_generate([
          {
            'name' => 'readers',
            'uri'  => server_url.join('/api/security/groups/readers'),
          },
          {
            'name' => 'tech-leads',
            'uri'  => server_url.join('/api/security/groups/tech-leads')
          }
        ])
      end

      app.get('/api/security/groups/readers') do
        content_type 'application/vnd.org.jfrog.artifactory.security.Group+json'
        JSON.fast_generate(
          'name'            => 'readers',
          'description'     => 'This list of read-only users',
          'autoJoin'        => true,
          'realm'           => 'artifactory',
          'realmAttributes' => nil,
        )
      end

      app.get('/api/security/groups/tech-leads') do
        content_type 'application/vnd.org.jfrog.artifactory.security.Group+json'
        JSON.fast_generate(
          'name'            => 'tech-leads',
          'description'     => 'This development leads group',
          'autoJoin'        => false,
          'realm'           => 'artifactory',
          'realmAttributes' => nil,
        )
      end

      app.put('/api/security/groups/:name') do
        return 415 unless request.content_type == 'application/vnd.org.jfrog.artifactory.security.Group+json'

        # Attempt to parse the response; if this succeeds, all is well...
        JSON.parse(request.body.read)
        nil
      end

      app.delete('/api/security/groups/:name') do
        nil
      end
    end
  end
end
