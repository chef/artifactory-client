require 'spec_helper'

module Artifactory
  describe Artifactory::Resource::VirtualRepository do
    describe '.from_hash' do
      let(:hash) do
        hash = {
          key: 'my-virtual-repo',
          rclass: 'virtual',
          packageType: 'debian',
          repositories: %w( repo1 repo2 ),
          description: 'my-description',
          notes: 'my-notes',
          includesPattern: '**/*',
          excludesPattern: '',
          debianTrivialLayout: 'false',
          artifactoryRequestsCanRetrieveRemoteArtifacts: false,
          keyPair: 'my-keypair',
          pomRepositoryReferencesCleanupPolicy: 'discard_active_reference'
        }

        hash
      end

      it 'creates an instance' do
        instance = described_class.from_hash(hash)

        expect(instance.key).to eql('my-virtual-repo')
        expect(instance.rclass).to eql('virtual')
        expect(instance.repositories).to match_array(%w( repo1 repo2 ))
        expect(instance.description).to eql('my-description')
        expect(instance.includes_pattern).to eql('**/*')
        expect(instance.excludes_pattern).to eql('')
        expect(instance.artifactory_requests_can_retrieve_remote_artifacts).to eql(false)
        expect(instance.key_pair).to eql('my-keypair')
        expect(instance.pom_repository_references_cleanup_policy).to eql('discard_active_reference')
      end
    end

    describe '#content_type' do
      it 'has proper content_type' do
        instance = described_class.new

        expect(instance.content_type).to eql('application/vnd.org.jfrog.artifactory.repositories.VirtualRepositoryConfiguration+json')
      end
    end
  end
end
