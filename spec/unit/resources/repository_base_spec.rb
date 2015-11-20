require 'spec_helper'

require 'artifactory/resources/repository_base'

module Artifactory
  shared_examples_for 'all-repositories' do
    subject { described_class.new }

    it 'defines self::RCLASS' do
      expect(defined?(described_class::RCLASS)).to eql('constant')
    end

    describe '#save' do
      let(:client) { double }

      before do
        subject.client = client
      end

      context 'when the repository is new' do
        it 'PUTS the file to the server' do
          subject.key = 'my-test-key'
          subject.rclass = 'local'

          allow(described_class).to receive(:find).with(subject.key, client: client).and_return(nil)

          expect(client).to receive(:put).with("/api/repositories/#{subject.key}", kind_of(String), kind_of(Hash))
          subject.save
        end
      end

      context 'when the repository exists' do
        before do
          subject.key = 'libs-releases-local'
          subject.rclass = 'local'

          allow(described_class).to receive(:find).with(subject.key, client: client).and_return({key: subject.key})
        end

        it 'POSTS the file to the server' do
          expect(client).to receive(:post).with("/api/repositories/#{subject.key}", kind_of(String), kind_of(Hash))
          subject.save
        end
      end

      it 'raises an exception when key is missing' do
        subject.rclass = 'temp' # set the other required attribute

        expect(->{ subject.save }).to raise_error('Key is missing!')
      end
    end
  end
  # create a test class to test the module functions
  class RepositoryBaseClass < Resource::Base
    RCLASS = 'test'

    include Artifactory::Resource::RepositoryBase

    def content_type
      'my-content-type'
    end
  end

  describe RepositoryBaseClass do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    it_behaves_like 'all-repositories'

    it 'defines an RCLASS' do
      expect(described_class::RCLASS).to eql('test')
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
        allow(described_class).to receive(:find).with('d', client: client).and_return('d')
      end

      it 'gets /api/repositories' do
        expect(client).to receive(:get).with('/api/repositories?type=test').once
        described_class.all
      end

      it 'returns the repositories that matches the rclass' do
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

    describe '#initialize' do
      subject { described_class.new }

      it 'responds to expected methods' do
        expect(subject.respond_to?(:key)).to eql(true)
        expect(subject.respond_to?(:rclass)).to eql(true)
      end
    end
  end

  class RepositoryBaseClassWithoutRCLASS < Resource::Base
    include Artifactory::Resource::RepositoryBase
  end

  describe RepositoryBaseClassWithoutRCLASS do
    it 'raises an exception when RCLASS is not defined' do
      expect(-> { described_class.all }).to raise_error('const RCLASS must be defined')
    end

    describe '#save' do
      let(:client) { double }

      before do
        subject.client = client
      end

      it 'raises an exception when rclass is missing' do
        subject.key = 'test-repo'

        allow(described_class).to receive(:find).with('test-repo', client: client).and_return('test-repo')
        expect(->{ subject.save }).to raise_error('rclass is missing!')
      end
    end

  end
end
