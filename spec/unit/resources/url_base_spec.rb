require 'spec_helper'

module Artifactory
  describe Resource::URLBase do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      doc = <<-XML
        <config>
          <urlBase>http://33.33.33.20/artifactory</urlBase>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the url bases' do
        expect(described_class.all).to be_a(Array)
        expect(described_class.all.first).to be_a(described_class)
        expect(described_class.all.first.url_base).to eq('http://33.33.33.20/artifactory')
      end
    end

    describe '.find' do
      doc = <<-XML
        <config>
          <urlBase>http://proxyserver/artifactory</urlBase>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the found urlBase' do
        expect(described_class.find('http://proxyserver/artifactory')).to be_a(described_class)
        expect(described_class.find('http://proxyserver/artifactory').url_base).to eq('http://proxyserver/artifactory')
      end
    end
  end
end
