require 'spec_helper'

module Artifactory
  describe Resource::System, :integration do
    describe '.info' do
      it 'gets the system information' do
        expect(described_class.info).to eq('This is some serious system info right here')
      end
    end

    describe '.ping' do
      it 'returns ok' do
        expect(described_class.ping).to be_truthy
      end
    end

    describe '.configuration' do
      it 'returns the system configuration' do
        expect(described_class.configuration).to be_a(REXML::Document)
      end
    end

    describe '.update_configuration' do
      let(:tempfile) { Tempfile.new(['config', 'xml']) }
      let(:content) do
        <<-EOH.strip.gsub(/^ {10}/, '')
          <?xml version='1.0' encoding='UTF-8' standalone='yes'?>
          <newConfig>true</newConfig>
        EOH
      end

      after do
        tempfile.close
        tempfile.unlink
      end

      it 'posts the new configuration to the server' do
        tempfile.write(content)
        tempfile.rewind

        expect(described_class.update_configuration(tempfile)).to eq(content)
      end
    end

    describe '.version' do
      it 'gets the version information' do
        expect(described_class.version).to eq({
          'version' => '3.1.0',
          'revision' => '30062',
          'addons' => [
            'ldap',
            'license',
            'yum'
          ]
        })
      end
    end
  end
end
