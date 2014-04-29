require 'spec_helper'

module Artifactory
  describe Resource::Layout do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:response) do
        [
          { 'name' => 'a' },
          { 'name' => 'b' }
        ]
      end

      it 'returns the layouts' do
        expect(described_class.all).to eq([ 'a', 'b'])
      end
    end

    describe '.find' do
      let(:response) { {} }

      it 'gets /api/repositories/#{name}' do
        expect(client).to receive(response)
      end
    end
  end
end
