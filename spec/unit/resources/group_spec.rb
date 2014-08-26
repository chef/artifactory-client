require 'spec_helper'

module Artifactory
  describe Resource::Group do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) do
        [
          { 'uri' => 'a' },
          { 'uri' => 'b' },
          { 'uri' => 'c' },
        ]
      end
      before do
        allow(described_class).to receive(:from_url).with('a', client: client).and_return('a')
        allow(described_class).to receive(:from_url).with('b', client: client).and_return('b')
        allow(described_class).to receive(:from_url).with('c', client: client).and_return('c')
      end

      it 'gets /api/security/groups' do
        expect(client).to receive(:get).with('/api/security/groups').once
        described_class.all
      end

      it 'returns the groups' do
        expect(described_class.all).to eq(['a', 'b', 'c'])
      end
    end

    describe '.find' do
      let(:response) { {} }

      it 'gets /api/repositories/#{name}' do
        expect(client).to receive(:get).with('/api/security/groups/readers').once
        described_class.find('readers')
      end
    end

    describe '.from_url' do
      let(:response) { {} }

      it 'constructs a new instance from the result' do
        expect(described_class).to receive(:from_hash).once
        described_class.from_url('/api/security/groups/readers')
      end
    end

    describe '.from_hash' do
      let(:hash) do
        {
          'name'            => 'readers',
          'description'     => 'This list of read-only users',
          'autoJoin'        => true,
          'realm'           => 'artifactory',
          'realmAttributes' => nil,
        }
      end

      it 'creates a new instance' do
        instance = described_class.from_hash(hash)
        expect(instance.name).to eq('readers')
        expect(instance.description).to eq('This list of read-only users')
        expect(instance.auto_join).to be_truthy
        expect(instance.realm).to eq('artifactory')
        expect(instance.realm_attributes).to be_nil
      end
    end

    describe '#save' do
      let(:client) { double }
      before do
        subject.client = client
        subject.name = 'deployers'
      end

      context 'when the group is new' do
        before do
          allow(described_class).to receive(:find).with(subject.name, client: client).and_return(nil)
        end

        it 'PUTS the group to the server' do
          expect(client).to receive(:put).with("/api/security/groups/#{subject.name}", kind_of(String), kind_of(Hash))
          subject.save
        end
      end

      context 'when the group exists' do
        before do
          allow(described_class).to receive(:find).with(subject.name, client: client).and_return({name: subject.name})
        end

        it 'POSTS the group to the server' do
          expect(client).to receive(:post).with("/api/security/groups/#{subject.name}", kind_of(String), kind_of(Hash))
          subject.save
        end
      end
    end
  end
end
