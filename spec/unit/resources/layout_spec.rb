require 'spec_helper'

module Artifactory
  describe Resource::Layout do
    let(:client) { double(:client) }

    before(:each) do
      Artifactory.stub(:client).and_return(client)
      client.stub(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      let(:xml) do
        REXML::Document.new('<config><repoLayouts><repoLayout><name>fake-layout</name></repoLayout></repoLayouts></config>')
      end

      before do
        Resource::System.stub(:configuration).and_return(xml)
      end

      it 'returns the layouts' do
        expect(described_class.all).to be_a(Array)
        expect(described_class.all.first).to be_a(described_class)
        expect(described_class.all.first.name).to eq('fake-layout')
      end
    end

    describe '.find' do
      let(:xml) do
        REXML::Document.new('<config><repoLayouts><repoLayout><name>found-layout</name></repoLayout></repoLayouts></config>')
      end

      before do
        Resource::System.stub(:configuration).and_return(xml)
      end

      it 'returns the found layout' do
        expect(described_class.find('found-layout')).to be_a(described_class)
        expect(described_class.find('found-layout').name).to eq('found-layout')
      end
    end
  end
end
