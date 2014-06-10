require 'spec_helper'

module Artifactory
  describe Resource::User, :integration do
    describe '.all' do
      it 'returns an array of user objects' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end

      it 'includes the information from the server' do
        results = described_class.all
        seth    = results[0]
        yvonne  = results[1]

        expect(seth.name).to eq('sethvargo')
        expect(yvonne.name).to eq('yzl')
      end
    end

    describe '.find' do
      it 'finds a user by name' do
        seth = described_class.find('sethvargo')

        expect(seth).to be_a(described_class)
        expect(seth.name).to eq('sethvargo')
      end
    end

    describe '#delete' do
      it 'deletes the user from the server' do
        sethvargo = described_class.find('sethvargo')
        expect(sethvargo.delete).to be_truthy
      end
    end

    describe '#save' do
      it 'saves the user to the server' do
        user = described_class.new(name: 'schisamo')
        expect(user.save).to be_truthy
      end
    end
  end
end
