require 'spec_helper'

module Artifactory
  describe Resource::Plugin do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) { ['a', 'b', 'c'] }

      it 'gets /api/plugins' do
        expect(client).to receive(:get).with('/api/plugins').once
        described_class.all
      end

      it 'returns the plugins' do
        expect(described_class.all).to eq(['a', 'b', 'c'])
      end
    end
  end
end
