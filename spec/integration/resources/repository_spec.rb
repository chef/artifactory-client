require 'spec_helper'

module Artifactory
  describe Resource::Repository, :integration do
    describe '.all' do
      it 'returns an array of repository objects' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a repository by key' do
        repository = described_class.find('libs-snapshots-local')

        expect(repository).to be_a(described_class)
        expect(repository.key).to eq('libs-snapshots-local')
        expect(repository.max_unique_snapshots).to eq(10)
      end
    end

    describe '#save' do
      it 'saves the repository to the server' do
        repository = described_class.new(key: 'libs-testing-local')
        expect(repository.save).to be_truthy
      end
    end
  end
end
