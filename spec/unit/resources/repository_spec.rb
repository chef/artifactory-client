require 'spec_helper'

module Artifactory
  describe Resource::Repository do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
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
        described_class.stub(:find).with('a', client: client).and_return('a')
        described_class.stub(:find).with('b', client: client).and_return('b')
        described_class.stub(:find).with('c', client: client).and_return('c')
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

      it 'creates a new instance' do
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
        expect(instance.rclass).to eq('local')
        expect(instance.snapshot_version_behavior).to eq('unique')
        expect(instance.suppress_pom_checks).to be_false
      end
    end

    describe '#save' do
      let(:client) { double }
      before do
        subject.client = client
        subject.key = 'libs-release-local'
      end

      it 'PUTS the file to the server' do
        expect(client).to receive(:put).with('/api/repositories/libs-release-local', kind_of(String), kind_of(Hash))
        subject.save
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
