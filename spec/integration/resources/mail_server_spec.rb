require 'spec_helper'

module Artifactory
  describe Resource::MailServer, :integration do
    describe '.all' do
      it 'returns an array of MailServer' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a MailServer by host' do
        smtp = described_class.find('smtp.gmail.com')

        expect(smtp).to be_a(described_class)
        expect(smtp.host).to eq('smtp.gmail.com')
      end
    end
  end
end
