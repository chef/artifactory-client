require 'spec_helper'

module Artifactory
  describe Resource::Artifact do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.search' do
      let(:response) { { 'results' => [] } }

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

    describe '#upload' do
      let(:client)     { double(put: {}) }
      let(:local_path) { '/local/path' }
      let(:file)       { double(File) }

      subject { described_class.new(client: client, local_path: local_path) }

      before do
        allow(File).to receive(:new).with(local_path).and_return(file)
      end

      context 'when the artifact is a file path' do
        it 'PUTs the file at the path to the server' do
          expect(client).to receive(:put).with('libs-release-local/remote/path', file, {})
          subject.upload('libs-release-local', '/remote/path')
        end
      end

      context 'when the md5 is available' do
        subject { described_class.new(client: client, local_path: local_path, checksums: { 'md5' => 'ABCDEF123456' } ) }

        it 'PUTs the file with the checksum headers set' do
          expect(client).to receive(:put).with('libs-release-local/remote/path', file, { 'X-Checksum-Md5' => 'ABCDEF123456' } )
          subject.upload('libs-release-local', '/remote/path')
        end
      end

      context 'when the sha1 is available' do
        subject { described_class.new(client: client, local_path: local_path, checksums: { 'sha1' => 'SHA1' } ) }

        it 'PUTs the file with the checksum headers set' do
          expect(client).to receive(:put).with('libs-release-local/remote/path', file, { 'X-Checksum-Sha1' => 'SHA1' } )
          subject.upload('libs-release-local', '/remote/path')
        end
      end

      context 'when matrix properties are given' do
        it 'converts the hash into matrix properties' do
          expect(client).to receive(:put).with('libs-release-local;branch=master;user=Seth/remote/path', file, {})

          subject.upload('libs-release-local', '/remote/path',
            branch: 'master',
            user: 'Seth',
          )
        end

        it 'converts spaces to "+" characters' do
          expect(client).to receive(:put).with('libs-release-local;user=Seth+Vargo/remote/path', file, {})

          subject.upload('libs-release-local', '/remote/path',
            user: 'Seth Vargo',
          )
        end

        it 'converts "+" to "%2B"' do
          expect(client).to receive(:put).with('libs-release-local;version=12.0.0-alpha.1%2B20140826080510.git.50.f5ff271/remote/path', file, {})

          subject.upload('libs-release-local', '/remote/path',
            version: '12.0.0-alpha.1+20140826080510.git.50.f5ff271',
          )
        end
      end

      context 'when custom headers are given' do
        it 'passes the headers to the client' do
          headers = { 'Content-Type' => 'text/plain' }
          expect(client).to receive(:put).with('libs-release-local/remote/path', file, headers)

          subject.upload('libs-release-local', '/remote/path', {}, headers)
        end
      end
    end

    describe '#upload_with_checksum' do
      it 'delegates to #upload' do
        expect(subject).to receive(:upload).with(
          'libs-release-local',
          '/remote/path',
          { branch: 'master' },
          {
            'X-Checksum-Deploy' => true,
            'X-Checksum-Sha1'   => 'ABCD1234',
          },
        )
        subject.upload_with_checksum('libs-release-local', '/remote/path', 'ABCD1234',
          { branch: 'master' },
        )
      end
    end

    describe '#upload_from_archive' do
      it 'delegates to #upload' do
        expect(subject).to receive(:upload).with(
          'libs-release-local',
          '/remote/path',
          {},
          { 'X-Explode-Archive' => true },
        )
        subject.upload_from_archive('libs-release-local', '/remote/path')
      end
    end

    describe '.gavc_search' do
      let(:response) { { 'results' => [] } }

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
      let(:response) { { 'results' => [] } }

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
      let(:response) { { 'results' => [] } }

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

    describe '.usage_search' do
      let(:response) { { 'results' => [] } }

      it 'calls /api/search/usage' do
        expect(client).to receive(:get).with('/api/search/usage', {}).once
        described_class.usage_search
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/usage',
          notUsedSince:  1414800000000,
          createdBefore: 1414871200000,
        ).once
        described_class.usage_search(
          notUsedSince:  1414800000000,
          createdBefore: 1414871200000,
          fizz: 'foo',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.usage_search).to be_a(Array)
      end
    end

    describe '.creation_search' do
      let(:response) { { 'results' => [] } }

      it 'calls /api/search/creation' do
        expect(client).to receive(:get).with('/api/search/creation', {}).once
        described_class.creation_search
      end

      it 'slices the correct parameters' do
        expect(client).to receive(:get).with('/api/search/creation',
          from:  1414800000000,
          to: 1414871200000,
        ).once
        described_class.creation_search(
          from:  1414800000000,
          to: 1414871200000,
          fizz: 'foo',
        )
      end

      it 'returns an array of objects' do
        expect(described_class.creation_search).to be_a(Array)
      end
    end

    describe '.versions' do
      let(:response) { { 'results' => [] } }

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
        allow(client).to receive(:get).and_raise(Error::HTTPError.new('status' => 404))

        result = described_class.versions
        expect(result).to be_a(Array)
        expect(result).to be_empty
      end
    end

    describe '.latest_version' do
      let(:response) { '1.2-SNAPSHOT' }

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
        allow(client).to receive(:get).and_raise(Error::HTTPError.new('status' => 404))

        expect(described_class.latest_version).to be_nil
      end
    end

    describe '.from_url' do
      let(:response) { {} }

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

      it 'creates a new instance' do
        instance = described_class.from_hash(hash)
        expect(instance).to be_a(described_class)
        expect(instance.uri).to eq('http://localhost:8080/artifactory/api/storage/libs-release-local/org/acme/lib/ver/lib-ver.pom')
        expect(instance.client).to be(client)
        expect(instance.created).to eq(Time.parse('2014-01-01 10:00 UTC'))
        expect(instance.download_uri).to eq('http://localhost:8080/artifactory/libs-release-local/org/acme/lib/ver/lib-ver.pom')
        expect(instance.last_modified).to eq(Time.parse('2014-01-01 11:00 UTC'))
        expect(instance.last_updated).to eq(Time.parse('2014-01-01 12:00 UTC'))
        expect(instance.md5).to eq('MD5123')
        expect(instance.mime_type).to eq('application/pom+xml')
        expect(instance.sha1).to eq('SHA456')
        expect(instance.size).to eq(1024)
      end
    end

    describe '#copy' do
      let(:destination) { '/to/here' }
      let(:options)     { Hash.new }
      before { allow(subject).to receive(:copy_or_move) }

      it 'delegates to #copy_or_move' do
        expect(subject).to receive(:copy_or_move).with(:copy, destination, options)
        subject.copy(destination, options)
      end
    end

    describe '#delete' do
      let(:client) { double }

      it 'sends DELETE to the client' do
        subject.client = client
        subject.download_uri = '/artifact.deb'

        expect(client).to receive(:delete)
        subject.delete
      end
    end

    describe '#move' do
      let(:destination) { '/to/here' }
      let(:options)     { Hash.new }
      before { allow(subject).to receive(:copy_or_move) }

      it 'delegates to #copy_or_move' do
        expect(subject).to receive(:copy_or_move).with(:move, destination, options)
        subject.move(destination, options)
      end
    end

    describe '#properties' do
      let(:properties) do
        { 'artifactory.licenses' => ['Apache-2.0'] }
      end
      let(:response) do
        { 'properties' => properties }
      end
      let(:client) { double(get: response) }
      let(:uri) { '/artifact.deb' }

      before do
        subject.client   = client
        subject.uri = uri
      end

      it 'gets the properties from the server' do
        expect(client).to receive(:get).with(uri, properties: nil).once
        expect(subject.properties).to eq(properties)
      end

      it 'caches the response' do
        subject.properties
        expect(subject.instance_variable_get(:@properties)).to eq(properties)
      end
    end

    describe '#compliance' do
      let(:compliance) do
        { 'licenses' => [{ 'name' => 'LGPL v3' }] }
      end
      let(:client) { double(get: compliance) }
      let(:uri) { '/artifact.deb' }

      before do
        subject.client   = client
        subject.uri = uri
      end

      it 'gets the compliance from the server' do
        expect(client).to receive(:get).with('/api/compliance/artifact.deb').once
        expect(subject.compliance).to eq(compliance)
      end

      it 'caches the response' do
        subject.compliance
        expect(subject.instance_variable_get(:@compliance)).to eq(compliance)
      end
    end

    describe '#download' do
      it
    end

    describe '#relative_path' do
      before { described_class.send(:public, :relative_path) }

      it 'parses the relative path' do
        subject.uri = '/api/storage/foo/bar/zip'
        expect(subject.relative_path).to eq('/foo/bar/zip')
      end
    end

    describe '#copy_or_move' do
      let(:client) { double }
      before do
        described_class.send(:public, :copy_or_move)

        subject.client   = client
        subject.uri = '/api/storage/foo/bar/artifact.deb'
      end

      it 'sends POST to the client with parsed params' do
        expect(client).to receive(:post).with('/api/move/foo/bar/artifact.deb?to=/to/path', {})
        subject.copy_or_move(:move, '/to/path')
      end

      it 'adds the correct parameters to the request' do
        expect(client).to receive(:post).with('/api/move/foo/bar/artifact.deb?to=/to/path&failFast=1&dry=1', {})
        subject.copy_or_move(:move, '/to/path', fail_fast: true, dry_run: true)
      end
    end
  end
end
