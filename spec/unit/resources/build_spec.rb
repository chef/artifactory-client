require 'spec_helper'

module Artifactory
  describe Resource::Build do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) { ['a', 'b', 'c'] }

      it 'gets /api/build' do
        expect(client).to receive(:get).with('/api/build').once
        described_class.all
      end

      context 'when there are builds' do
        it 'returns the builds' do
          expect(described_class.all).to eq(['a', 'b', 'c'])
        end
      end

      context 'when the system has no builds' do
        it 'returns an empty array' do
          client.stub(:get).and_raise(Error::NotFound)
          expect(described_class.all).to be_empty
        end
      end
    end
  end
end
