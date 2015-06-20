require 'spec_helper'

module Artifactory
  describe Resource::Build, :integration do
    describe '.all' do
      it 'returns an array of build objects' do
        results = described_class.all('wicket')
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a build by component and number' do
        build = described_class.find('wicket', 51)

        expect(build).to be_a(described_class)
        expect(build.name).to eq('wicket')
        expect(build.number).to eq('51')
        expect(build.started).to eq(Time.parse('2014-09-30T12:00:19.893+0300'))
      end
    end

    describe '#save' do
      it 'saves the build data to the server' do
        build = described_class.new(
          name: 'fricket',
          number: '1',
          properties: {
            'buildInfo.env.JAVA_HOME' => '/usr/jdk/latest'
        })

        expect(build.save).to be_truthy
      end
    end
  end
end
