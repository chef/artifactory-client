require 'spec_helper'

module Artifactory
  describe Resource::PermissionTarget, :integration do
    describe '.all' do
      it 'returns an array of PermissionTarget objects' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end

      it 'includes the information from the server' do
        results = described_class.all
        anything = results[0]
        any_remote   = results[1]

        expect(anything.name).to eq('Anything')
        expect(any_remote.name).to eq('Any Remote')
      end
    end

    describe '.find' do
      it 'finds a permission target by name' do
        readers = described_class.find('Anything')

        expect(readers).to be_a(described_class)
        expect(readers.name).to eq('Anything')
      end
    end

    describe '#delete' do
      it 'deletes the permission target from the server' do
        readers = described_class.find('Anything')
        expect(readers.delete).to be_truthy
      end
    end

    describe '#save' do
      it 'saves the permission target to the server' do
        target = described_class.new(name: 'testing')
        expect(target.save).to be_truthy
      end
    end

    describe '#users' do
      it 'displays the users hash with sorted verbose permissions' do
        target = described_class.find('Any Remote')
        expect(target.users).to eq( { 'anonymous' => ['deploy', 'read'] } )
      end
    end

    describe '#groups' do
      it 'displays the groups hash with sorted verbose permissions' do
        target = described_class.find('Anything')
        expect(target.groups).to eq( { 'readers' => ['admin', 'read'] } )
      end
    end

    describe '#users=' do
      it 'sets the users hash' do
        target = described_class.find('Any Remote')
        target.users = { 'admins' => ['admin'] }
        expect(target.users).to eq( { 'admins' => ['admin'] })
      end
    end

    describe '#groups=' do
      it 'sets the groups hash' do
        target = described_class.find('Anything')
        target.groups = { 'deployers' => ['deploy'] }
        expect(target.groups).to eq( { 'deployers' => ['deploy'] })
      end
    end
  end
end
