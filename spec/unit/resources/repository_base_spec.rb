require 'spec_helper'

require 'artifactory/resources/repository_base'

module Artifactory
  # create a test class to test the module functions
  class RepositoryBaseClass < Resource::Base
    include Artifactory::Resource::RepositoryBase
  end

  describe RepositoryBaseClass do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) do
        [
          { 'key' => 'a' },
          { 'key' => 'b' },
          { 'key' => 'c' },
        ]
      end
      before do
        allow(described_class).to receive(:find).with('a', client: client).and_return('a')
        allow(described_class).to receive(:find).with('b', client: client).and_return('b')
        allow(described_class).to receive(:find).with('c', client: client).and_return('c')
      end

      it 'gets /api/repositories' do
        expect(client).to receive(:get).with('/api/repositories').once
        described_class.all
      end

      it 'returns the repositories' do
        expect(described_class.all).to eq(['a', 'b', 'c'])
      end
    end

    describe '.find' do
      let(:response) { {} }

      it 'gets /api/repositories/#{name}' do
        expect(client).to receive(:get).with('/api/repositories/libs-release-local').once
        described_class.find('libs-release-local')
      end
    end

    describe '.from_hash' do
      let(:hash) do
        hash = {
          key: 'my-key'
        }
      end

      it 'creates an instance' do
        instance = described_class.from_hash(hash)

        expect(instance.key).to eql('my-key')
      end
    end

    describe 'instance' do
      subject { described_class.new }

      it 'responds to expected methods' do
        expect(subject.respond_to?(:key)).to eql(true)
      end
    end
  end
end
