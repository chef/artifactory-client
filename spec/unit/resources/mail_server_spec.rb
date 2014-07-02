require 'spec_helper'

module Artifactory
  describe Resource::MailServer do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      doc = <<-XML
        <config>
          <mailServer>
            <host>smtp.gmail.com</host>
          </mailServer>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the mail server settings' do
        expect(described_class.all).to be_a(Array)
        expect(described_class.all.first).to be_a(described_class)
        expect(described_class.all.first.host).to eq('smtp.gmail.com')
      end
    end

    describe '.find' do
      doc = <<-XML
        <config>
          <mailServer>
            <host>mailserver.example.com</host>
          </mailServer>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the found mail server setting' do
        expect(described_class.find('mailserver.example.com')).to be_a(described_class)
        expect(described_class.find('mailserver.example.com').host).to eq('mailserver.example.com')
      end
    end
  end
end
