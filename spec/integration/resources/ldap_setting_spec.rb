require 'spec_helper'

module Artifactory
  describe Resource::LDAPSetting, :integration do
    describe '.all' do
      it 'returns an array of LdapSetting' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds an LdapSetting by key' do
        ldap = described_class.find('example-ldap')

        expect(ldap).to be_a(described_class)
        expect(ldap.key).to eq('example-ldap')
      end
    end
  end
end
