require 'spec_helper'

module Artifactory
  describe Resource::LDAPSetting do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe '.all' do
      doc = <<-XML
        <config>
          <security>
            <ldapSettings>
              <ldapSetting>
                <key>example-ldap</key>
              </ldapSetting>
            </ldapSettings>
          </security>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the ldap settings' do
        expect(described_class.all).to be_a(Array)
        expect(described_class.all.first).to be_a(described_class)
        expect(described_class.all.first.key).to eq('example-ldap')
      end
    end

    describe '.find' do
      doc = <<-XML
        <config>
          <security>
            <ldapSettings>
              <ldapSetting>
                <key>viridian-ldap</key>
              </ldapSetting>
            </ldapSettings>
          </security>
        </config>
      XML
      let(:xml) do
        REXML::Document.new(doc)
      end

      before do
        allow(Resource::System).to receive(:configuration).and_return(xml)
      end

      it 'returns the found ldap setting' do
        expect(described_class.find('viridian-ldap')).to be_a(described_class)
        expect(described_class.find('viridian-ldap').key).to eq('viridian-ldap')
      end
    end
  end
end
