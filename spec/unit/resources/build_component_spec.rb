require 'spec_helper'

module Artifactory
  describe Resource::BuildComponent do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
      subject.name = 'wicket'
    end

    describe '.all' do
      let(:response) do
        {
          'uri'    => "#{Artifactory.endpoint}/api/build",
          'builds' => [
            {
              'uri'         => "/wicket",
              'lastStarted' => '2015-06-19T20:13:20.222Z',
            },
            {
              'uri'         => "/jackrabbit",
              'lastStarted' => '2015-06-20T20:13:20.333Z',
            },
          ]
        }
      end

      before do
        allow(described_class).to receive(:from_hash).with(hash_including('uri' => '/wicket'), client: client).and_return('wicket')
        allow(described_class).to receive(:from_hash).with(hash_including('uri' => '/jackrabbit'), client: client).and_return('jackrabbit')
      end

      it 'GETS /api/build' do
        expect(client).to receive(:get).with('/api/build').once
        described_class.all
      end

      context 'when there are components with builds' do
        it 'returns the components' do
          expect(described_class.all).to eq(%w( wicket jackrabbit ))
        end
      end

      context 'when the system has no components with builds' do
        it 'returns an empty array' do
          allow(client).to receive(:get).and_raise(Error::HTTPError.new('status' => 404))
          expect(described_class.all).to be_empty
        end
      end
    end

    describe '.find' do
      before do
        allow(described_class).to receive(:all).and_return([
          described_class.new(name: 'wicket'),
          described_class.new(name: 'jackrabbit')
        ])
      end

      it 'filters the full build component list by name' do
        expect(described_class.find('wicket')).to_not be_nil
      end

      context 'when the build component does not exist' do
        it 'returns nil' do
          expect(described_class.find('fricket')).to be_nil
        end
      end
    end

    describe '.from_hash' do
      let(:time) { Time.now.utc.round }
      let(:hash) do
        {
          'uri'         => '/wicket',
          'lastStarted' => time.iso8601(3),
        }
      end

      it 'creates a new instance' do
        instance = described_class.from_hash(hash)
        expect(instance.uri).to eq('/wicket')
        expect(instance.name).to eq('wicket')
        expect(instance.last_started).to eq(time)
      end
    end

    describe '#builds' do

      it 'returns a build collection' do
        expect(subject.builds).to be_a(Collection::Build)
      end
    end

    describe '#delete' do

      it 'sends DELETE to the client' do
        expect(client).to receive(:delete)
        subject.delete
      end

      it 'adds the correct parameters to the request' do
        expect(client).to receive(:delete).with('/api/build/wicket?buildNumbers=51,52,55&artifacts=1&deleteAll=1', {})
        subject.delete(build_numbers: %w( 51 52 55 ), artifacts: true, delete_all: true)
      end
    end

    describe '#rename' do

      it 'sends POST to the client with the correct param' do
        expect(client).to receive(:post).with('/api/build/rename/wicket?to=fricket', {})
        subject.rename('fricket')
      end
    end
  end
end
