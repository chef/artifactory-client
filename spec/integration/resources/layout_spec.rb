require 'spec_helper'

module Artifactory
  describe Resource::Layout, :integration do
    describe '.all' do
      it 'returns an array of Layouts' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a layout by name' do
        mvn_layout = described_class.find('maven-2-default')

        expect(mvn_layout).to be_a(described_class)
        expect(mvn_layout.name).to eq('maven-2-default')
      end
    end
  end
end
