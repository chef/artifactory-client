require 'spec_helper'

module Artifactory
  describe Resource::Artifact do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
    end

    describe '.search' do
      let(:response) { double(json: { 'results' => [] }) }

      it 'calls /api/search/artifact' do
        expect(client).to receive(:get).with('/api/search/artifact', {}).once
        described_class.search
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/artifact',
          name:  'name',
          repos: 'repo',
        ).once
        described_class.search(
          name:  'name',
          repos: 'repo',
          fizz:  'foo',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.search).to be_a(Array)
      end
    end

    describe '.gavc_search' do
      let(:response) { double(json: { 'results' => [] }) }

      it 'calls /api/search/gavc' do
        expect(client).to receive(:get).with('/api/search/gavc', {}).once
        described_class.gavc_search
      end

      it 'renames the parameters' do
        expect(client).to receive(:get).with('/api/search/gavc',
          g: 'group',
          a: 'name',
          v: 'version',
          c: 'classifier',
        ).once
        described_class.gavc_search(
          group:      'group',
          name:       'name',
          version:    'version',
          classifier: 'classifier',
        )
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/gavc',
          g: 'group',
          a: 'name',
        ).once
        described_class.gavc_search(
          group:'group',
          name: 'name',
          fizz: 'foo',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.gavc_search).to be_a(Array)
      end
    end

    describe '.property_search' do
      let(:response) { double(json: { 'results' => [] }) }

      it 'calls /api/search/prop' do
        expect(client).to receive(:get).with('/api/search/prop', {}).once
        described_class.property_search
      end

      it 'passes all the parameters' do
        expect(client).to receive(:get).with('/api/search/prop',
          p1: 'v1',
          p2: 'v2',
        ).once
        described_class.property_search(
          p1: 'v1',
          p2: 'v2',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.property_search).to be_a(Array)
      end
    end

    describe '.checksum_search' do
      let(:response) { double(json: { 'results' => [] }) }

      it 'calls /api/search/checksum' do
        expect(client).to receive(:get).with('/api/search/checksum', {}).once
        described_class.checksum_search
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/checksum',
          md5:  'MD5123',
          sha1: 'SHA456',
        ).once
        described_class.checksum_search(
          md5:  'MD5123',
          sha1: 'SHA456',
          fizz: 'foo',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.checksum_search).to be_a(Array)
      end
    end

    describe '.versions' do
      let(:response) { double(json: { 'results' => [] }) }

      it 'calls /api/search/versions' do
        expect(client).to receive(:get).with('/api/search/versions', {}).once
        described_class.versions
      end

      it 'renames the parameters' do
        expect(client).to receive(:get).with('/api/search/versions',
          g: 'group',
          a: 'name',
          v: 'version',
        ).once
        described_class.versions(
          group:      'group',
          name:       'name',
          version:    'version',
        )
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/versions',
          g: 'group',
          a: 'name',
        ).once
        described_class.versions(
          group:'group',
          name: 'name',
          fizz: 'foo',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.versions).to be_a(Array)
      end

      it 'returns an empty array when the server responses with a 404' do
        client.stub(:get).and_raise(Error::NotFound)

        result = described_class.versions
        expect(result).to be_a(Array)
        expect(result).to be_empty
      end
    end

    describe '.latest_version' do
      let(:response) { double(body: '1.2-SNAPSHOT') }

      it 'calls /api/search/latestVersion' do
        expect(client).to receive(:get).with('/api/search/latestVersion', {}).once
        described_class.latest_version
      end

      it 'renames the parameters' do
        expect(client).to receive(:get).with('/api/search/latestVersion',
          g: 'group',
          a: 'name',
          v: 'version',
        ).once
        described_class.latest_version(
          group:      'group',
          name:       'name',
          version:    'version',
        )
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/latestVersion',
          g: 'group',
          a: 'name',
        ).once
        described_class.latest_version(
          group:'group',
          name: 'name',
          fizz: 'foo',
        )
      end

      it 'returns the latest version' do
        expect(described_class.latest_version).to eq('1.2-SNAPSHOT')
      end

      it 'returns an nil when the server responses with a 404' do
        client.stub(:get).and_raise(Error::NotFound)

        expect(described_class.latest_version).to be_nil
      end
    end

    describe '.from_url' do
      let(:response) { double(json: {}) }

      it 'constructs a new instance from the result' do
        expect(described_class).to receive(:from_hash).once
        described_class.from_url('/some/artifact/path.deb')
      end
    end

    describe '.from_hash' do
      let(:hash) do
        {
          'uri'              => 'http://localhost:8080/artifactory/api/storage/libs-release-local/org/acme/lib/ver/lib-ver.pom',
          'downloadUri'      => 'http://localhost:8080/artifactory/libs-release-local/org/acme/lib/ver/lib-ver.pom',
          'repo'             => 'libs-release-local',
          'path'             => '/org/acme/lib/ver/lib-ver.pom',
          'remoteUrl'        => 'http://some-remote-repo/mvn/org/acme/lib/ver/lib-ver.pom',
          'created'          => '2014-01-01 10:00 UTC',
          'createdBy'        => 'userY',
          'lastModified'     => '2014-01-01 11:00 UTC',
          'modifiedBy'       => 'userX',
          'lastUpdated'      => '2014-01-01 12:00 UTC',
          'size'             => '1024',
          'mimeType'         => 'application/pom+xml',
          'checksums'        => { 'md5' => 'MD5123', 'sha1' => 'SHA456' },
          'originalChecksums'=> { 'md5' => 'MD5123', 'sha1' => 'SHA456' },
        }
      end

      it 'creates a new instnace' do
        instance = described_class.from_hash(hash)
        expect(instance).to be_a(described_class)
        expect(instance.api_path).to eq('http://localhost:8080/artifactory/api/storage/libs-release-local/org/acme/lib/ver/lib-ver.pom')
        expect(instance.client).to be(client)
        expect(instance.created).to eq(Time.parse('2014-01-01 10:00 UTC'))
        expect(instance.download_path).to eq('http://localhost:8080/artifactory/libs-release-local/org/acme/lib/ver/lib-ver.pom')
        expect(instance.last_modified).to eq(Time.parse('2014-01-01 11:00 UTC'))
        expect(instance.last_updated).to eq(Time.parse('2014-01-01 12:00 UTC'))
        expect(instance.md5).to eq('MD5123')
        expect(instance.mime_type).to eq('application/pom+xml')
        expect(instance.sha1).to eq('SHA456')
        expect(instance.size).to eq(1024)
      end
    end
  end
end
