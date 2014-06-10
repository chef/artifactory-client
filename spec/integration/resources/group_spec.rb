require 'spec_helper'

module Artifactory
  describe Resource::Group, :integration do
    describe '.all' do
      it 'returns an array of group objects' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end

      it 'includes the information from the server' do
        results = described_class.all
        readers = results[0]
        leads   = results[1]

        expect(readers.name).to eq('readers')
        expect(leads.name).to eq('tech-leads')
      end
    end

    describe '.find' do
      it 'finds a group by name' do
        readers = described_class.find('readers')

        expect(readers).to be_a(described_class)
        expect(readers.name).to eq('readers')
      end
    end

    describe '#delete' do
      it 'deletes the group from the server' do
        readers = described_class.find('readers')
        expect(readers.delete).to be_truthy
      end
    end

    describe '#save' do
      it 'saves the group to the server' do
        group = described_class.new(name: 'testing')
        expect(group.save).to be_truthy
      end
    end
  end
end
