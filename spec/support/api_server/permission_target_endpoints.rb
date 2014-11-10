module Artifactory
  module APIServer::PermissionTargetEndpoints
    def self.registered(app)
      app.get('/api/security/permissions') do
        content_type 'application/vnd.org.jfrog.artifactory.security.PermissionTargets+json'
        JSON.fast_generate([
          {
            'name' => 'Anything',
            'uri'  => server_url.join('/api/security/permissions/Anything'),
          },
          {
            'name' => 'Any Remote',
            'uri'  => server_url.join('/api/security/permissions/Any%20Remote')
          }
        ])
      end

      app.get('/api/security/permissions/Any%20Remote') do
        content_type 'application/vnd.org.jfrog.artifactory.security.PermissionTargets+json'
        JSON.fast_generate(
          'name'             => 'Any Remote',
          'includes_pattern'  => nil,
          'excludes_pattern' => '',
          'repositories'     => ["ANY REMOTE"],
          'principals'       => { 'users' => { 'anonymous' => ['w', 'r'] }, 'groups' => nil }
        )
      end

      app.get('/api/security/permissions/Anything') do
        content_type 'application/vnd.org.jfrog.artifactory.security.PermissionTargets+json'
        JSON.fast_generate(
          'name'             => 'Anything',
          'includes_pattern'  => nil,
          'excludes_pattern' => '',
          'repositories'     => ["ANY"],
          'principals'       =>  { 'users' => { 'anonymous' => ['r'] }, 'groups' => { 'readers' => ['r', 'm'] } }
        )
      end

      app.put('/api/security/permissions/:name') do
        return 415 unless request.content_type == 'application/vnd.org.jfrog.artifactory.security.PermissionTarget+json'

        # Attempt to parse the response; if this succeeds, all is well...
        JSON.parse(request.body.read)
        nil
      end

      app.delete('/api/security/permissions/:name') do
        nil
      end
    end
  end
end
