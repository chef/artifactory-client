require 'spec_helper'

module Artifactory
  describe Resource::PermissionTarget do
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

      it 'gets /api/security/permissions' do
        expect(client).to receive(:get).with('/api/security/permissions').once
        described_class.all
      end

      it 'returns the permissions' do
        expect(described_class.all).to eq(['a', 'b', 'c'])
      end
    end

    describe '.find' do
      let(:response) { {} }

      it 'gets /api/security/permissions/#{name}' do
        expect(client).to receive(:get).with('/api/security/permissions/Any%20Remote').once
        described_class.find('Any Remote')
      end
    end

    describe '.from_url' do
      let(:response) { {} }

      it 'constructs a new instance from the result' do
        expect(described_class).to receive(:from_hash).once
        described_class.from_url('/api/security/permissions/Any Remote')
      end
    end

    describe '.from_hash' do
      let(:hash) do
        {
          'name'             => 'Any Remote',
          'include_pattern'  => nil,
          'excludes_pattern' => '',
          'repositories'     => ["ANY REMOTE"],
          'users'            => {"anonymous"=>["w", "r"]},
          'groups'           => nil
        }
      end

      it 'creates a new instance' do
        instance = described_class.from_hash(hash)
        expect(instance.name).to eq('Any Remote')
        expect(instance.include_pattern).to eq(nil)
        expect(instance.excludes_pattern).to eq('')
        expect(instance.repositories).to eq(["ANY REMOTE"])
        expect(instance.users).to eq({"anonymous"=>["w", "r"]})
        expect(instance.groups).to eq(nil)
      end
    end
  end
end
