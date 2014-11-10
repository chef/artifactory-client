require 'spec_helper'

module Artifactory
  describe Resource::Artifact, :integration do
    shared_examples 'an artifact search endpoint' do |name, options = {}|
      it "finds artifacts by #{name}" do
        response = described_class.send(name, options)
        expect(response).to be_a(Array)
        expect(response.size).to eq(2)

        artifact_1 = response[0]
        expect(artifact_1).to be_a(described_class)
        expect(artifact_1.repo).to eq('libs-release-local')

        artifact_2 = response[1]
        expect(artifact_2).to be_a(described_class)
        expect(artifact_2.repo).to eq('ext-release-local')
      end

      it "finds artifacts by repo" do
        response = described_class.send(name, options.merge(repos: 'libs-release-local'))
        expect(response).to be_a(Array)
        expect(response.size).to eq(1)

        artifact = response.first
        expect(artifact).to be_a(described_class)
        expect(artifact.repo).to eq('libs-release-local')
      end
    end

    describe '.search' do
      it_behaves_like 'an artifact search endpoint', :search, name: 'artifact.deb'
    end

    describe '.gavc_search' do
      it_behaves_like 'an artifact search endpoint', :gavc_search, {
        group:      'org.acme',
        name:       'artifact.deb',
        version:    '1.0',
        classifier: 'sources',
      }
    end

    describe '.property_search' do
      it_behaves_like 'an artifact search endpoint', :property_search, {
        branch:    'master',
        committer: 'Seth Vargo',
      }
    end

    describe '.checksum_search' do
      it_behaves_like 'an artifact search endpoint', :checksum_search, md5: 'abcd1234'
    end

    describe '.usage_search' do
      it_behaves_like 'an artifact search endpoint', :usage_search, notUsedSince: '1414800000'
    end

    describe '.creation_search' do
      it_behaves_like 'an artifact search endpoint', :creation_search, from: '1414800000'
    end

    describe '.versions' do
      it 'returns an array of versions' do
        response = described_class.versions
        expect(response).to be_a(Array)
        expect(response.size).to eq(3)

        expect(response[0]['version']).to eq('1.2')
      end
    end

    describe '.latest_version' do
      it 'finds the latest version of the artifact' do
        response = described_class.latest_version
        expect(response).to be_a(String)
        expect(response).to eq('1.0-201203131455-2')
      end
    end
  end
end
