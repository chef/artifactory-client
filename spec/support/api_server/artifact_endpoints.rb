module Artifactory
  module APIServer::ArtifactEndpoints
    def self.registered(app)
      app.get('/api/search/artifact') do
        content_type 'application/vnd.org.jfrog.artifactory.search.ArtifactSearchResult+json'
        artifacts_for_conditions do
          params['name'] == 'artifact.deb'
        end
      end

      app.get('/api/search/gavc') do
        content_type 'application/vnd.org.jfrog.artifactory.search.GavcSearchResult+json'
        artifacts_for_conditions do
          params['g'] == 'org.acme' &&
          params['a'] == 'artifact.deb' &&
          params['v'] == '1.0' &&
          params['c'] == 'sources'
        end
      end

      app.get('/api/search/prop') do
        content_type 'application/vnd.org.jfrog.artifactory.search.MetadataSearchResult+json'
        artifacts_for_conditions do
          params['branch'] == 'master' && params['committer'] == 'Seth Vargo'
        end
      end

      app.get('/api/search/checksum') do
        content_type 'application/vnd.org.jfrog.artifactory.search.ChecksumSearchResult+json'
        artifacts_for_conditions do
          params['md5'] == 'abcd1234'
        end
      end

      app.get('/api/search/usage') do
        content_type 'application/vnd.org.jfrog.artifactory.search.ArtifactUsageResult+json'
        artifacts_for_conditions do
          params['notUsedSince'] == '1414800000'
        end
      end

      app.get('/api/search/creation') do
        content_type 'application/vnd.org.jfrog.artifactory.search.ArtifactCreationResult+json'
        artifacts_for_conditions do
          params['from'] == '1414800000'
        end
      end

      app.get('/api/search/versions') do
        content_type 'application/vnd.org.jfrog.artifactory.search.ArtifactVersionsResult+json'
        JSON.fast_generate(
          'results' => [
            { 'version' => '1.2',          'integration' => false },
            { 'version' => '1.0-SNAPSHOT', 'integration' => true  },
            { 'version' => '1.0',          'integration' => false },
          ]
        )
      end

      app.get('/api/search/latestVersion') do
        '1.0-201203131455-2'
      end

      app.get('/api/storage/libs-release-local/org/acme/artifact.deb') do
        content_type 'application/vnd.org.jfrog.artifactory.storage.FileInfo+json'
        JSON.fast_generate(
          'uri'          => server_url.join('/api/storage/libs-release-local/org/acme/artifact.deb'),
          'downloadUri'  => server_url.join('/artifactory/libs-release-local/org/acme/artifact.deb'),
          'repo'         => 'libs-release-local',
          'path'         => '/org/acme/artifact.deb',
          'created'      => Time.parse('1991-07-23 12:07am'),
          'createdBy'    => 'schisamo',
          'lastModified' => Time.parse('2013-12-24 11:50pm'),
          'modifiedBy'   => 'sethvargo',
          'lastUpdated'  => Time.parse('2014-01-01 1:00pm'),
          'size'         => '1024',
          'mimeType'     => 'application/tgz',
          'checksums'    => {
            'md5' => 'MD5123',
            'sha' => 'SHA456'
          },
          'originalChecksums' => {
            'md5' => 'MD5123',
            'sha' => 'SHA456'
          }
        )
      end

      app.get('/api/storage/ext-release-local/org/acme/artifact.deb') do
        content_type 'application/vnd.org.jfrog.artifactory.storage.FileInfo+json'
        JSON.fast_generate(
          'uri'          => server_url.join('/api/storage/ext-release-local/org/acme/artifact.deb'),
          'downloadUri'  => server_url.join('/artifactory/ext-release-local/org/acme/artifact.deb'),
          'repo'         => 'ext-release-local',
          'path'         => '/org/acme/artifact.deb',
          'created'      => Time.parse('1995-04-11 11:05am'),
          'createdBy'    => 'yzl',
          'lastModified' => Time.parse('2013-11-10 10:10pm'),
          'modifiedBy'   => 'schisamo',
          'lastUpdated'  => Time.parse('2014-02-02 2:00pm'),
          'size'         => '1024',
          'mimeType'     => 'application/tgz',
          'checksums'    => {
            'md5' => 'MD5789',
            'sha' => 'SHA101'
          },
          'originalChecksums' => {
            'md5' => 'MD5789',
            'sha' => 'SHA101'
          }
        )
      end

      app.class_eval do
        def artifacts_for_conditions(&block)
          if block.call
            if params['repos'] == 'libs-release-local'
              JSON.fast_generate(
                'results' => [
                  { 'uri' => server_url.join('/api/storage/libs-release-local/org/acme/artifact.deb') },
                ]
              )
            else
              JSON.fast_generate(
                'results' => [
                  { 'uri' => server_url.join('/api/storage/libs-release-local/org/acme/artifact.deb') },
                  { 'uri' => server_url.join('/api/storage/ext-release-local/org/acme/artifact.deb') },
                ]
              )
            end
          end
        end
      end
    end
  end
end
