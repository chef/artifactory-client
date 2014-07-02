require 'spec_helper'

module Artifactory
  describe Resource::Backup do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      doc = <<-XML
        <config>
          <backups>
            <backup>
              <key>backup-daily</key>
            </backup>
          </backups>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the backup settings' do
        expect(described_class.all).to be_a(Array)
        expect(described_class.all.first).to be_a(described_class)
        expect(described_class.all.first.key).to eq('backup-daily')
      end
    end

    describe '.find' do
      doc = <<-XML
        <config>
          <backups>
            <backup>
              <key>backup-weekly</key>
            </backup>
          </backups>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the found backup setting' do
        expect(described_class.find('backup-weekly')).to be_a(described_class)
        expect(described_class.find('backup-weekly').key).to eq('backup-weekly')
      end
    end
  end
end
