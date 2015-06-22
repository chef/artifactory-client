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
          'name'             => 'Test Remote',
          'includes_pattern'  => '**',
          'excludes_pattern' => '',
          'repositories'     => ['ANY REMOTE'],
          'principals'       => { 'users' => { 'anonymous' => ['w', 'r'] }, 'groups'  => {} }
        }
      end

      it 'creates a new instance' do
        instance = described_class.from_hash(hash)
        expect(instance.name).to eq('Test Remote')
        expect(instance.includes_pattern).to eq('**')
        expect(instance.excludes_pattern).to eq('')
        expect(instance.repositories).to eq(['ANY REMOTE'])
        expect(instance.principals).to eq({ 'users' => { 'anonymous' => ['deploy', 'read'] }, 'groups' => {} })
      end
    end

    describe Artifactory::Resource::PermissionTarget::Principal do
      context 'principal object' do
        users = { 'anonymous_users' => ['admin', 'deploy', 'read'] }
        groups = { 'anonymous_groups' => ['delete', 'read'] }
        instance = described_class.new(users, groups)

        it 'has unabbreviated users' do
          expect(instance.users).to eq( { 'anonymous_users' => ['admin', 'deploy', 'read'] } )
        end

        it 'has unabbreviated groups' do
          expect(instance.groups).to eq( { 'anonymous_groups' => ['delete', 'read'] } )
        end

        it 'abbreviates' do
          expect(instance.to_abbreviated).to eq( { 'users' => { 'anonymous_users' => ['m', 'r', 'w'] }, 'groups' => { 'anonymous_groups' => ['d', 'r'] } } )
        end
      end
    end

    describe '#save' do
      let(:client) { double }
      before do
        subject.client = client
        subject.name = 'TestRemote'
        subject.includes_pattern = nil
        subject.excludes_pattern = ''
        subject.repositories = ['ANY']
        subject.principals = {
          'users' => {
            'anonymous_users' => ['read']
          },
          'groups' => {
            'anonymous_readers' => ['read']
          }
        }
        allow(described_class).to receive(:find).with(subject.name, client: client).and_return(nil)
      end

      it 'PUTS the permission target to the server' do
        expect(client).to receive(:put).with("/api/security/permissions/TestRemote",
          "{\"name\":\"TestRemote\",\"includesPattern\":\"**\",\"excludesPattern\":\"\",\"repositories\":[\"ANY\"],\"principals\":{\"users\":{\"anonymous_users\":[\"r\"]},\"groups\":{\"anonymous_readers\":[\"r\"]}}}",
          { "Content-Type" => "application/vnd.org.jfrog.artifactory.security.PermissionTarget+json"})
        subject.save
      end
    end

    describe '#delete' do
      let(:client) { double }

      it 'sends DELETE to the client' do
        subject.client = client
        subject.name = 'My Permissions'

        expect(client).to receive(:delete).with('/api/security/permissions/My%20Permissions')
        subject.delete
      end
    end

    describe 'getters' do
      let(:client) { double }
      before do
        subject.client = client
        subject.name = 'TestGetters'
        subject.principals = {
          'users' => {
            'anonymous' => ['read']
          },
          'groups' => {
            'readers' => ['read']
          }
        }
        allow(described_class).to receive(:find).with(subject.name, client: client).and_return(nil)
      end

      it '#users returns the users hash' do
        expect(subject.users).to eq({ 'anonymous' => ['read'] })
      end

      it '#groups returns the groups hash' do
        expect(subject.groups).to eq({ 'readers' => ['read'] })
      end
    end

    describe 'setters' do
      let(:client) { double }
      before do
        subject.client = client
        subject.name = 'TestSetters'
        subject.principals = {
          'users' => {
            'anonymous' => ['read']
          },
          'groups' => {
            'readers' => ['read']
          }
        }
        allow(described_class).to receive(:find).with(subject.name, client: client).and_return(nil)
      end

      it '#users= sets the users hash' do
        subject.users = { 'spiders' => [ 'read', 'admin'] }
        expect(subject.users).to eq({ 'spiders' => ['admin', 'read'] })
      end

      it '#groups= sets the groups hash' do
        subject.groups = { 'beatles' => [ 'deploy', 'delete'] }
        expect(subject.groups).to eq({ 'beatles' => ['delete', 'deploy'] })
      end
    end
  end
end
