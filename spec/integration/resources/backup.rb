require 'spec_helper'

module Artifactory
  describe Resource::Backup, :integration do
    describe '.all' do
      it 'returns an array of Backups' do
        results = described_class.all
        expect(results).to be_a(Array)
        expect(results.first).to be_a(described_class)
      end
    end

    describe '.find' do
      it 'finds a Backup by key' do
        backup = described_class.find('backup-daily')

        expect(backup).to be_a(described_class)
        expect(backup.key).to eq('backup-daily')
      end
    end
  end
end
