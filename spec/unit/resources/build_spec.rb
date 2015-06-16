require 'spec_helper'

module Artifactory
  describe Resource::Build do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) do
        {
          'uri'    => "#{Artifactory.endpoint}/api/build",
          'builds' => builds
        }
      end

      let(:builds) do
        [
          {
            'uri'         => '/wicket',
            'lastStarted' => '2014-01-01 12:00:00',
          },
          {
            'uri'         => '/jackrabbit',
            'lastStarted' => '2014-02-11 10:00:00',
          }
        ]
      end

      it 'gets /api/build' do
        expect(client).to receive(:get).with('/api/build').once
        described_class.all
      end

      context 'when there are builds' do
        it 'returns the builds' do
          expect(described_class.all).to eq(builds)
        end
      end

      context 'when the system has no builds' do
        it 'returns an empty array' do
          allow(client).to receive(:get).and_raise(Error::HTTPError.new('status' => 404))
          expect(described_class.all).to be_empty
        end
      end
    end
  end
end
