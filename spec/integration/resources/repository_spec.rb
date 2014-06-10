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

    describe '#save' do
      it 'saves the repository to the server' do
        repository = described_class.new(key: 'libs-testing-local')
        expect(repository.save).to be_truthy
      end
    end
  end
end
