require 'spec_helper'

module Artifactory
  describe Resource::RemoteRepository do
    subject(:repository) { described_class.new }
    let(:hash) do
      {
        'key' => 'remote-repo1',
        'rclass' => 'remote',
        'packageType' => 'maven',
        'url' => 'http://host:port/some-repo',
        'username' => 'remote-repo-user',
        'password' => 'pass',
        'proxy' => 'proxy1',
        'description' => 'The remote repository public description',
        'notes' => 'Some internal notes',
        'includesPattern' => '**/*',
        'excludesPattern' => '',
        'remoteRepoChecksumPolicyType' => 'generate-if-absent',
        'handleReleases' => true,
        'handleSnapshots' => true,
        'maxUniqueSnapshots' => 0,
        'suppressPomConsistencyChecks' => false,
        'hardFail' => false,
        'offline' => false,
        'blackedOut' => false,
        'storeArtifactsLocally' => true,
        'socketTimeoutMillis' => 15000,
        'localAddress' => '212.150.139.167',
        'retrievalCachePeriodSecs' => 43200,
        'failedRetrievalCachePeriodSecs' => 30,
        'missedRetrievalCachePeriodSecs' => 7200,
        'unusedArtifactsCleanupEnabled' => false,
        'unusedArtifactsCleanupPeriodHours' => 0,
        'fetchJarsEagerly' => false,
        'fetchSourcesEagerly' => false,
        'shareConfiguration' => false,
        'synchronizeProperties' => false,
        'propertySets' => ['ps1', 'ps2'],
        'allowAnyHostAuth' => false,
        'enableCookieManagement' => false,
        'bowerRegistryUrl' => 'https://bower.herokuapp.com',
        'vcsType' => 'GIT',
        'vcsGitProvider' => 'GITHUB',
        'vcsGitDownloadUrl' => ''
      }
    end

    it 'has a proper content type' do
      # rubocop:disable LineLength
      expected = 'application/vnd.org.jfrog.artifactory.repositories.RemoteRepositoryConfiguration+json'

      expect(repository.content_type).to eql(expected)
    end

    it 'supports proper attributes' do
      instance = described_class.from_hash(hash)

      expect(instance.key).to eql('remote-repo1')
      expect(instance.rclass).to eql('remote')
      expect(instance.package_type).to eql('maven')
      expect(instance.username).to eql('remote-repo-user')
      expect(instance.password).to eql('pass')
      expect(instance.proxy).to eql('proxy1')
      expect(instance.description).to eql('The remote repository public description')
      expect(instance.notes).to eql('Some internal notes')
      expect(instance.includes_pattern).to eql('**/*')
      expect(instance.excludes_pattern).to eql('')
      expect(instance.remote_repo_checksum_policy_type).to eql('generate-if-absent')
      expect(instance.handle_releases).to eql(true)
      expect(instance.handle_snapshots).to eql(true)
      expect(instance.max_unique_snapshots).to eql(0)
      expect(instance.suppress_pom_consistency_checks).to eql(false)
      expect(instance.hard_fail).to eql(false)
      expect(instance.offline).to eql(false)
      expect(instance.blacked_out).to eql(false)
      expect(instance.store_artifacts_locally).to eql(true)
      expect(instance.socket_timeout_millis).to eql(15000)
      expect(instance.local_address).to eql('212.150.139.167')
      expect(instance.retrieval_cache_period_secs).to eql(43200)
      expect(instance.failed_retrieval_cache_period_secs).to eql(30)
      expect(instance.missed_retrieval_cache_period_secs).to eql(7200)
      expect(instance.unused_artifacts_cleanup_enabled).to eql(false)
      expect(instance.unused_artifacts_cleanup_period_hours).to eql(0)
      expect(instance.fetch_jars_eagerly).to eql(false)
      expect(instance.fetch_sources_eagerly).to eql(false)
      expect(instance.share_configuration).to eql(false)
      expect(instance.synchronize_properties).to eql(false)
      expect(instance.property_sets).to eql(['ps1', 'ps2'])
      expect(instance.allow_any_host_auth).to eql(false)
      expect(instance.enable_cookie_management).to eql(false)
      expect(instance.bower_registry_url).to eql('https://bower.herokuapp.com')
      expect(instance.vcs_type).to eql('GIT')
      expect(instance.vcs_git_provider).to eql('GITHUB')
      expect(instance.vcs_git_download_url).to eql('')
    end

    describe '#save' do
      let(:client) { double }
      before do
        subject.client = client
        subject.key = 'libs-release-local'
        subject.url = 'http://remote-url'
      end

      context 'when the repository is new' do
        before do
          allow(described_class).to receive(:find).with(subject.key, client: client).and_return(nil)
        end

        it 'PUTS the file to the server' do
          expect(client).to receive(:put).with("/api/repositories/#{subject.key}", kind_of(String), kind_of(Hash))
          subject.save
        end
      end

      context 'when the repository exists' do
        before do
          allow(described_class).to receive(:find).with(subject.key, client: client).and_return({key: subject.key})
        end

        it 'POSTS the file to the server' do
          expect(client).to receive(:post).with("/api/repositories/#{subject.key}", kind_of(String), kind_of(Hash))
          subject.save
        end
      end
    end
  end
end
