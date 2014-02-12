require 'spec_helper'

module Artifactory
  describe Resource::User do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
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
        described_class.stub(:from_url).with('a', client: client).and_return('a')
        described_class.stub(:from_url).with('b', client: client).and_return('b')
        described_class.stub(:from_url).with('c', client: client).and_return('c')
      end

      it 'gets /api/security/users' do
        expect(client).to receive(:get).with('/api/security/users').once
        described_class.all
      end

      it 'returns the users' do
        expect(described_class.all).to eq(['a', 'b', 'c'])
      end
    end

    describe '.find' do
      let(:response) { {} }

      it 'gets /api/repositories/#{name}' do
        expect(client).to receive(:get).with('/api/security/users/readers').once
        described_class.find('readers')
      end
    end

    describe '.from_url' do
      let(:response) { {} }

      it 'constructs a new instance from the result' do
        expect(described_class).to receive(:from_hash).once
        described_class.from_url('/api/security/users/readers')
      end
    end

    describe '.from_hash' do
      let(:hash) do
        {
          'admin'                    => false,
          'email'                    => 'admin@example.com',
          'groups'                   => ['admin'],
          'internalPasswordDisabled' => true,
          'lastLoggedIn'             => nil,
          'name'                     => 'admin',
          'profileUpdatable'         => true,
          'realm'                    => 'artifactory',
        }
      end

      it 'creates a new instnace' do
        instance = described_class.from_hash(hash)
        expect(instance.admin).to be_false
        expect(instance.email).to eq('admin@example.com')
        expect(instance.groups).to eq(['admin'])
        expect(instance.internal_password_disabled).to be_true
        expect(instance.last_logged_in).to be_nil
        expect(instance.name).to eq('admin')
        expect(instance.password).to be_nil
        expect(instance.profile_updatable).to be_true
        expect(instance.realm).to eq('artifactory')
      end
    end
  end
end
