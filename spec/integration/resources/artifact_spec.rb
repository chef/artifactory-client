require 'spec_helper'

module Artifactory
  describe Resource::Artifact, :integration do
    describe '.search' do
      it 'finds artifacts by name' do
        response = described_class.search(name: 'artifact.deb')
        expect(response).to be_a(Array)
        expect(response.size).to eq(2)

        artifact_1 = response[0]
        expect(artifact_1).to be_a(described_class)
        expect(artifact_1.repo).to eq('libs-release-local')

        artifact_2 = response[1]
        expect(artifact_2).to be_a(described_class)
        expect(artifact_2.repo).to eq('ext-release-local')
      end

      it 'finds artifacts by repo' do
        response = described_class.search(name: 'artifact.deb', repos: 'libs-release-local')
        expect(response).to be_a(Array)
        expect(response.size).to eq(1)

        artifact = response.first
        expect(artifact).to be_a(described_class)
        expect(artifact.repo).to eq('libs-release-local')
      end
    end

    describe '.gavc_search' do
      it
    end

    describe '.property_search' do
      it
    end

    describe '.checksum_search' do
      it
    end

    describe '.versions' do
      it
    end

    describe '.latest_version' do
      it
    end
  end
end
