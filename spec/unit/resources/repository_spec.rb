require 'spec_helper'

module Artifactory
  describe Resource::Repository do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) { ['a', 'b', 'c'] }

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
        described_class.find(name: 'libs-release-local')
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
          'rclass'                       => 'local',
        }
      end

      it 'creates a new instnace' do
        instance = described_class.from_hash(hash)
        expect(instance.blacked_out).to be_false
        expect(instance.description).to eq('Local repository for in-house libraries')
        expect(instance.checksum_policy).to eq('client-checksums')
        expect(instance.excludes_pattern).to eq('')
        expect(instance.handle_releases).to be_true
        expect(instance.handle_snapshots).to be_false
        expect(instance.includes_pattern).to eq('**/*')
        expect(instance.key).to eq('libs-release-local')
        expect(instance.maximum_unique_snapshots).to eq(0)
        expect(instance.notes).to eq('')
        expect(instance.property_sets).to eq(['artifactory'])
        expect(instance.snapshot_version_behavior).to eq('unique')
        expect(instance.suppress_pom_checks).to be_false
        expect(instance.type).to eq('local')
      end
    end

    describe '#upload' do
      let(:client) { double }
      before do
        subject.client = client
        subject.key    = 'libs-release-local'
      end

      context 'when the artifact is a File' do
        it 'PUTs the file to the server' do
          file = double(:file, is_a?: true)
          expect(client).to receive(:put).with('libs-release-local/remote/path', { file: file }, {})

          subject.upload(file, '/remote/path')
        end
      end

      context 'when the artifact is a file path' do
        it 'PUTs the file at the path to the server' do
          file = double(:file)
          path = '/fake/path'
          File.stub(:new).with('/fake/path').and_return(file)
          expect(client).to receive(:put).with('libs-release-local/remote/path', { file: file }, {})

          subject.upload(path, '/remote/path')
        end
      end

      context 'when matrix properties are given' do
        it 'converts the hash into matrix properties' do
          file = double(:file, is_a?: true)
          expect(client).to receive(:put).with('libs-release-local;branch=master;user=Seth%20Vargo/remote/path', { file: file }, {})

          subject.upload(file, '/remote/path',
            branch: 'master',
            user: 'Seth Vargo',
          )
        end
      end

      context 'when custom headers are given' do
        it 'passes the headers to the client' do
          headers = { 'Content-Type' => 'text/plain' }
          file = double(:file, is_a?: true)
          expect(client).to receive(:put).with('libs-release-local/remote/path', { file: file }, headers)

          subject.upload(file, '/remote/path', {}, headers)
        end
      end
    end

    describe '#upload_with_checksum' do
      it 'delegates to #upload' do
        expect(subject).to receive(:upload).with(
          '/local/file',
          '/remote/path',
          { branch: 'master' },
          {
            'X-Checksum-Deploy' => true,
            'X-Checksum-Sha1'   => 'ABCD1234',
          },
        )
        subject.upload_with_checksum('/local/file', '/remote/path',
          'ABCD1234',
          { branch: 'master' },
        )
      end
    end

    describe '#upload_from_archive' do
      it 'delegates to #upload' do
        expect(subject).to receive(:upload).with(
          '/local/file',
          '/remote/path',
          {},
          {
            'X-Explode-Archive' => true,
          },
        )
        subject.upload_from_archive('/local/file', '/remote/path')
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
