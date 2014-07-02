require 'spec_helper'

module Artifactory
  describe Resource::URLBase, :integration do
    describe '.all' do
      it 'returns an array of UrlBases' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a urlBase by url' do
        base = described_class.find('http://33.33.33.20/artifactory')

        expect(base).to be_a(described_class)
        expect(base.url_base).to eq('http://33.33.33.20/artifactory')
      end
    end
  end
end
