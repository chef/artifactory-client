module Artifactory
  module APIServer::UserEndpoints
    def self.registered(app)
      app.get('/api/security/users') do
        content_type 'application/vnd.org.jfrog.artifactory.security.Users+json'
        JSON.fast_generate([
          {
            'name' => 'sethvargo',
            'uri'  => server_url.join('/api/security/users/sethvargo'),
          },
          {
            'name' => 'yzl',
            'uri'  => server_url.join('/api/security/users/yzl')
          }
        ])
      end

      app.get('/api/security/users/sethvargo') do
        content_type 'application/vnd.org.jfrog.artifactory.security.User+json'
        JSON.fast_generate(
          'admin'                    => false,
          'email'                    => 'sethvargo@gmail.com',
          'groups'                   => ['admin'],
          'internalPasswordDisabled' => true,
          'lastLoggedIn'             => nil,
          'name'                     => 'sethvargo',
          'profileUpdatable'         => true,
          'realm'                    => 'artifactory',
        )
      end

      app.get('/api/security/users/yzl') do
        content_type 'application/vnd.org.jfrog.artifactory.security.User+json'
        JSON.fast_generate(
          'admin'                    => true,
          'email'                    => 'yvonne@getchef.com',
          'groups'                   => ['admin'],
          'internalPasswordDisabled' => true,
          'lastLoggedIn'             => nil,
          'name'                     => 'yzl',
          'profileUpdatable'         => true,
          'realm'                    => 'crowd',
        )
      end

      app.put('/api/security/users/:name') do
        return 415 unless request.content_type == 'application/vnd.org.jfrog.artifactory.security.User+json'

        # Attempt to parse the response; if this succeeds, all is well...
        JSON.parse(request.body.read)
        nil
      end

      app.delete('/api/security/users/:name') do
        nil
      end
    end
  end
end
