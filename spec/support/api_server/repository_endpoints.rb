module Artifactory
  module APIServer::RepositoryEndpoints
    def self.registered(app)
      app.get('/api/repositories') do
        content_type 'application/vnd.org.jfrog.artifactory.repositories.RepositoryDetailsList+json'
        JSON.fast_generate([
          {
            'key'         => 'libs-release-local',
            'type'        => 'LOCAL',
            'description' => 'Local repository for in-house libraries',
            'url'         => server_url.join('libs-release-local'),
          },
          {
            'key'         => 'libs-snapshots-local',
            'type'        => 'LOCAL',
            'description' => 'Local repository for in-house snapshots',
            'url'         => server_url.join('libs-snapshots-local'),
          },
        ])
      end

      app.get('/api/repositories/libs-release-local') do
        content_type 'application/vnd.org.jfrog.artifactory.repositories.LocalRepositoryConfiguration+json'
        JSON.fast_generate({
          'key'                          => 'libs-release-local',
          'description'                  => 'Local repository for in-house libraries',
          'notes'                        => '',
          'includesPattern'              => '**/*',
          'excludesPattern'              => '',
          'repoLayoutRef'                => 'maven-2-default',
          'enableNuGetSupport'           => false,
          'enableGemsSupport'            => false,
          'checksumPolicyType'           => 'client-checksums',
          'handleReleases'               => true,
          'handleSnapshots'              => false,
          'maxUniqueSnapshots'           => 0,
          'snapshotVersionBehavior'      => 'unique',
          'suppressPomConsistencyChecks' => false,
          'blackedOut'                   => false,
          'propertySets'                 => ['artifactory'],
          'archiveBrowsingEnabled'       => false,
          'calculateYumMetadata'         => false,
          'yumRootDepth'                 => 0,
          'rclass'                       => 'local'
        })
      end

      app.get('/api/repositories/libs-snapshots-local') do
        content_type 'application/vnd.org.jfrog.artifactory.repositories.LocalRepositoryConfiguration+json'
        JSON.fast_generate({
          'key'                          => 'libs-snapshots-local',
          'description'                  => 'Local repository for in-house snapshots',
          'notes'                        => '',
          'includesPattern'              => '**/*',
          'excludesPattern'              => '',
          'repoLayoutRef'                => 'maven-2-default',
          'enableNuGetSupport'           => false,
          'enableGemsSupport'            => false,
          'checksumPolicyType'           => 'client-checksums',
          'handleReleases'               => false,
          'handleSnapshots'              => true,
          'maxUniqueSnapshots'           => 10,
          'snapshotVersionBehavior'      => 'unique',
          'suppressPomConsistencyChecks' => false,
          'blackedOut'                   => false,
          'propertySets'                 => ['artifactory'],
          'archiveBrowsingEnabled'       => false,
          'calculateYumMetadata'         => false,
          'yumRootDepth'                 => 0,
          'rclass'                       => 'local'
        })
      end

      # Simulate a non-existent repository
      app.get('/api/repositories/libs-testing-local') do
        status 400
      end

      app.put('/api/repositories/libs-testing-local') do
        content_type 'text/plain'
        "Repository libs-resting-local created successfully!\n"
      end
    end
  end
end
