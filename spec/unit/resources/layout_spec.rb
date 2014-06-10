require 'spec_helper'

module Artifactory
  describe Resource::Layout do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      doc = <<-XML
        <config>
          <repoLayouts>
            <repoLayout>
              <name>fake-layout</name>
            </repoLayout>
          </repoLayouts>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the layouts' do
        expect(described_class.all).to be_a(Array)
        expect(described_class.all.first).to be_a(described_class)
        expect(described_class.all.first.name).to eq('fake-layout')
      end
    end

    describe '.find' do
      doc = <<-XML
        <config>
          <repoLayouts>
            <repoLayout>
              <name>found-layout</name>
            </repoLayout>
          </repoLayouts>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the found layout' do
        expect(described_class.find('found-layout')).to be_a(described_class)
        expect(described_class.find('found-layout').name).to eq('found-layout')
      end
    end
  end
end
