require 'spec_helper'

module Artifactory
  describe Resource::System do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.info' do
      let(:response) { 'This is the response...' }

      it 'calls /api/system' do
        expect(client).to receive(:get).with('/api/system').once
        described_class.info
      end

      it 'returns the plan-text body' do
        expect(described_class.info).to eq(response)
      end
    end

    describe '.ping' do
      let(:response) { '' }

      it 'gets /api/system/ping' do
        expect(client).to receive(:get).with('/api/system/ping').once
        described_class.ping
      end

      context 'when the system is ok' do
        it 'returns true' do
          expect(described_class.ping).to be_truthy
        end
      end

      context 'when the system is not running' do
        it 'returns false' do
          allow(client).to receive(:get)
            .and_raise(Error::ConnectionError.new(Artifactory.endpoint))
          expect(described_class.ping).to be_falsey
        end
      end
    end

    describe '.configuration' do
      let(:response) { '<config></config>' }

      it 'gets /api/system/configuration' do
        expect(client).to receive(:get).with('/api/system/configuration').once
        described_class.configuration
      end

      it 'returns the xml' do
        expect(described_class.configuration).to be_a(REXML::Document)
      end
    end

    describe '.update_configuration' do
      let(:xml) { double(:xml) }
      let(:response) { double(body: '...') }
      before { allow(client).to receive(:post).and_return(response) }

      it 'posts /api/system/configuration' do
        headers = { 'Content-Type' => 'application/xml' }
        expect(client).to receive(:post).with('/api/system/configuration', xml, headers).once
        described_class.update_configuration(xml)
      end

      it 'returns the body of the response' do
        expect(described_class.update_configuration(xml)).to eq(response)
      end
    end

    describe '.version' do
      let(:response) { double(json: { 'foo' => 'bar' }) }

      it 'gets /api/system/version' do
        expect(client).to receive(:get).with('/api/system/version').once
        described_class.version
      end

      it 'returns the parsed JSON of the response' do
        expect(described_class.version).to eq(response)
      end
    end
  end
end
