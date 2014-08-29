require 'spec_helper'

module Artifactory
  describe Resource::Repository do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) do
        [
          { 'key' => 'a' },
          { 'key' => 'b' },
          { 'key' => 'c' },
        ]
      end
      before do
        allow(described_class).to receive(:find).with('a', client: client).and_return('a')
        allow(described_class).to receive(:find).with('b', client: client).and_return('b')
        allow(described_class).to receive(:find).with('c', client: client).and_return('c')
      end

      it 'gets /api/repositories' do
        expect(client).to receive(:get).with('/api/repositories').once
        described_class.all
      end

      it 'returns the repositories' do
        expect(described_class.all).to eq(['a', 'b', 'c'])
      end
    end

    describe '.find' do
      let(:response) { {} }

      it 'gets /api/repositories/#{name}' do
        expect(client).to receive(:get).with('/api/repositories/libs-release-local').once
        described_class.find('libs-release-local')
      end
    end

    describe '.from_hash' do
      let(:hash) do
        {
          'key'                          => 'libs-release-local',
          'description'                  => 'Local repository for in-house libraries',
          'notes'                        => '',
          'includesPattern'              => '**/*',
          'excludesPattern'              => '',
          'repoLayoutRef'                => 'maven-2-default',
          'enableNuGetSupport'           => false,
          'enableGemsSupport'            => false,
          'checksumPolicyType'           => 'server-generated-checksums',
          'handleReleases'               => true,
          'handleSnapshots'              => false,
          'maxUniqueSnapshots'           => 10,
          'snapshotVersionBehavior'      => 'unique',
          'suppressPomConsistencyChecks' => true,
          'blackedOut'                   => false,
          'propertySets'                 => ['artifactory'],
          'archiveBrowsingEnabled'       => false,
          'calculateYumMetadata'         => false,
          'yumRootDepth'                 => 0,
          'rclass'                       => 'local',
        }
      end

      it 'creates a new instance' do
        instance = described_class.from_hash(hash)
        expect(instance.blacked_out).to be_falsey
        expect(instance.description).to eq('Local repository for in-house libraries')
        expect(instance.checksum_policy_type).to eq('server-generated-checksums')
        expect(instance.excludes_pattern).to eq('')
        expect(instance.handle_releases).to be_truthy
        expect(instance.handle_snapshots).to be_falsey
        expect(instance.includes_pattern).to eq('**/*')
        expect(instance.key).to eq('libs-release-local')
        expect(instance.max_unique_snapshots).to eq(10)
        expect(instance.notes).to eq('')
        expect(instance.property_sets).to eq(['artifactory'])
        expect(instance.rclass).to eq('local')
        expect(instance.snapshot_version_behavior).to eq('unique')
        expect(instance.suppress_pom_consistency_checks).to be_truthy
      end
    end

    describe '#save' do
      let(:client) { double }
      before do
        subject.client = client
        subject.key = 'libs-release-local'
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

    describe '#upload' do
      let(:client) { double(put: {}) }
      let(:file) { double(File) }
      let(:path) { '/fake/path' }
      before do
        subject.client = client
        subject.key    = 'libs-release-local'
        allow(File).to receive(:new).with('/fake/path').and_return(file)
      end

      context 'when the artifact is a file path' do
        it 'PUTs the file at the path to the server' do
          expect(client).to receive(:put).with('libs-release-local/remote/path', file, {})

          subject.upload(path, '/remote/path')
        end
      end

      context 'when matrix properties are given' do
        it 'converts the hash into matrix properties' do
          expect(client).to receive(:put).with('libs-release-local;branch=master;user=Seth+Vargo%2B1/remote/path', file, {})

          subject.upload(path, '/remote/path',
            branch: 'master',
            user: 'Seth Vargo+1',
          )
        end

        it 'converts the hash into matrix properties' do
          expect(client).to receive(:put).with('libs-release-local;branch=master;user=Seth/remote/path', file, {})

          subject.upload(path, '/remote/path',
            branch: 'master',
            user: 'Seth',
          )
        end

        it 'converts spaces to "+" characters' do
          expect(client).to receive(:put).with('libs-release-local;user=Seth+Vargo/remote/path', file, {})

          subject.upload(path, '/remote/path',
            user: 'Seth Vargo',
          )
        end

        it 'converts "+" to "%2B"' do
          expect(client).to receive(:put).with('libs-release-local;version=12.0.0-alpha.1%2B20140826080510.git.50.f5ff271/remote/path', file, {})

          subject.upload(path, '/remote/path',
            version: '12.0.0-alpha.1+20140826080510.git.50.f5ff271',
          )
        end
      end

      context 'when custom headers are given' do
        it 'passes the headers to the client' do
          headers = { 'Content-Type' => 'text/plain' }
          expect(client).to receive(:put).with('libs-release-local/remote/path', file, headers)

          subject.upload(path, '/remote/path', {}, headers)
        end
      end
    end

    describe '#artifacts' do
      before { subject.key = 'libs-release-local' }

      it 'returns an artifact collection' do
        expect(subject.artifacts).to be_a(Collection::Artifact)
      end
    end
  end
end
